[public:assoc] SAML
SAML['authtemplate']=""
SAML['idpxml']=""
SAML['spurl']=""
SAML['spxml']=""
SAML['logoutresponsexml']=""
SAML['logoutrequestxml']=""
SAML['privkey']=""

Saml::idGen(){
    printf '%s' "$(String::Generate::UUID)"
}

Saml::request::id(){
    SAMLREQUEST['ID']="$(Saml::idGen)"
}

Saml::request::assertion(){
    ! [[ -z "${SAML['spurl']}" ]] && SAMLREQUEST['AssertionConsumerServiceURL']="${SAML['spurl']%/}/acs"
}

Saml::request::issueinstant(){
    SAMLREQUEST['IssueInstant']="$(date +%Y-%m-%dT%H:%M:%SZ)"
}

Saml::request::destination(){
    SAMLREQUEST['Destination']="$(xmlstarlet sel -t -v '//*[name()="SingleSignOnService"]/@Location' ${SAML['idpxml']})"
}

Saml::buildXmlFile(){
    [private] _opts 
    [public:assoc] SAMLREQUEST

    Saml::request::id
    Saml::request::assertion
    Saml::request::issueinstant
    Saml::request::destination

    for key in "${!SAMLREQUEST[@]}"; do
        _opts+=" -u '//*[name()=\"AuthnRequest\"]/@$key' -v \"${SAMLREQUEST[$key]}\""
    done
    
    _opts+=" -u '//*[name()=\"saml:Issuer\"]' -v \"${SAML['spurl']}\""

    eval "xmlstarlet ed $_opts ${SAML['authtemplate']}"

    unset _opts
}

Saml::createRelayState(){
    tmpSaml['RelayState']="$(Saml::idGen)"
}

Saml::createSamlRequest(){
    Saml::buildXmlFile | phpdeflate.php -M deflate -s | base64 -w0
}

Saml::createSignature(){   
    [private] _query_string="$*"

    printf '%s' "$_query_string" | openssl dgst -sha1 -sign "${SAML['privkey']}" | base64 -w0
}

Saml::buildAuthnRequest(){
    [private] _query
    [private:assoc] tmpSaml

    if Session::check; then
        Http::send::redirect temporary /
        return
    fi

    tmpSaml['SAMLRequest']="$(Saml::createSamlRequest)"
    Saml::createRelayState
    tmpSaml['SigAlg']="http://www.w3.org/2000/09/xmldsig#rsa-sha1"


    for key in "${!tmpSaml[@]}"; do
        _query+="$key=$(printf '%s' "${tmpSaml[$key]}" | urlencode.pl)&"
    done


    _query="${_query%&}&Signature=$(Saml::createSignature "SAMLRequest=$( printf '%s' "${tmpSaml['SAMLRequest']}" | urlencode.pl )&RelayState=$(printf '%s' "${tmpSaml['RelayState']}" | urlencode.pl )&SigAlg=$(printf '%s' "${tmpSaml['SigAlg']}" | urlencode.pl)" | urlencode.pl)"
#    _query="${_query%&}&Signature=$(urlencode "$(Saml::createSignature "SAMLRequest=$( urlencode "${tmpSaml['SAMLRequest']}")&RelayState=$(urlencode "${tmpSaml['RelayState']}")&SigAlg=$(urlencode "${tmpSaml['SigAlg']}")")")"

    Http::send::redirect temporary "$(xmlstarlet sel -t -v '//*[name()="SingleSignOnService"]/@Location' ${SAML['idpxml']})?${_query%&}"

}


Saml::validate::Issuer(){
    [private] xmlResponse="$1" 
    [private] idpIssuer 
    [private] responseIssuer

    responseIssuer="$(printf '%s' "$xmlResponse" | xmlstarlet sel -t -v '//*[name()="saml:Issuer"]')"
    idpIssuer="$(xmlstarlet sel -t -v '//*[name()="SingleSignOnService"]/@Location' ${SAML['idpxml']})"
    idpIssuer="${idpIssuer//\/sso/}"

    [[ "$responseIssuer" == "$idpIssuer" ]] || return 1
}

Saml::validate::Sign(){
    [private] xmlResponse="$1" 
    [private] xmlCert 
    [private] xmlSigned 
    [private] xmltoCheck 
    [private] result 
    [private] tmpXmlFile="$(Mktemp::create)" 
    [private] tmpCert="$(Mktemp::create)"
    [private] attrID="$2"

    printf '%s\n' "$xmlResponse" > $tmpXmlFile

    cat $tmpXmlFile

    printf -- '-----BEGIN CERTIFICATE-----\n%s\n-----END CERTIFICATE-----\n' "$(printf '%s' "$xmlResponse" | xmlstarlet sel -t -v '//*[name()="ds:X509Certificate"]')" > $tmpCert

    xmlsec1 verify --id-attr:ID "urn:oasis:names:tc:SAML:2.0:protocol:$attrID" --pubkey-cert-pem $tmpCert $tmpXmlFile &>/dev/null || return 1
}

Saml::get::Assertion(){
    [private]  xmlResponse="$1"

    printf "$xmlResponse" | xmlstarlet sel -t -v '//*[name()="AttributeStatement"]/*[name()="Attribute"][@Name="http://schemas.xmlsoap.org/claims/CommonName"]'
}

Saml::retrieve::Identity(){
    [private] xmlResponse
    [private] username
    [private] decodedXmlResponse
    [private] username
    [private] xmlTmpFile="$(Mktemp::create)"
    
    [[ -z "${POST['SAMLResponse']}" ]] && { Saml::buildAuthnRequest; return 1; }

    xmlResponse="$(printf '%s' "${POST['SAMLResponse']}" | base64 -d)"

    printf '%s' "$xmlResponse" > $xmlTmpFile

    decodedXmlResponse="$(xmlsec1 --decrypt --privkey-pem ${SAML['privkey']} $xmlTmpFile)"

    Saml::validate::Issuer "$xmlResponse" || { Saml::buildAuthnRequest; return 1; }
    Saml::validate::Sign "$xmlResponse" "Response" || { Saml::buildAuthnRequest; return 1; }

    Session::start

    Json::to::array SESSION "$(printf '%s' "$decodedXmlResponse" | xmlstarlet sel -t -v '//*[name()="AttributeStatement"]/*[name()="Attribute"][@Name="user_entity"]')"

    Session::set USERNAME ${SESSION['user_name']}
    
    Session::save

    Http::send::cookie "USERNAME=${SESSION['USERNAME']}; Max-Age=$default_session_expiration"

    Http::send::redirect temporary /
}

Saml::validate::NameId(){
    [private] xmlResponse="$1"

    if [[ "$(printf '%s' "$xmlResponse" | xmlstarlet sel -t -v '//*[name()="saml:NameID"]')" == "$(Session::get USERNAME)" ]]; then
        return 0
    else
        return 1
    fi
}

Saml::Logout(){

    if [[ -z "${POST['SAMLRequest']}" ]]; then
        if Session::check; then
            Saml::build::LogoutRequest
        else
            Http::send::redirect temporary /
            exit
        fi
    else
        Saml::validate::LogoutRequest
    fi

}

Saml::build::LogoutRequestXml(){
    [private] _opts
    [public:assoc] SAMLREQUEST

    Saml::request::id
    Saml::request::issueinstant
    Saml::request::destination

    for key in "${!SAMLREQUEST[@]}"; do
        _opts+=" -u '//*[name()=\"LogoutRequest\"]/@$key' -v \"${SAMLREQUEST[$key]}\""
    done

    _opts+=" -u '//*[name()=\"saml:Issuer\"]' -v \"${SAML['spurl']}\""
    _opts+=" -u '//*[name()=\"saml:NameID\"]/@SPNameQualifier' -v \"${SAML['spurl']}\""
    _opts+=" -u '//*[name()=\"saml:NameID\"]' -v \"$(Session::get USERNAME)\""

    eval "xmlstarlet ed $_opts ${SAML['logoutrequestxml']}"

    unset _opts
}

Saml::createLogoutRequest(){
    Saml::build::LogoutRequestXml | phpdeflate.php -M deflate -s | base64 -w0
}

Saml::build::LogoutRequest(){
    [private] _query
    [private:assoc] tmpSaml

    tmpSaml['SAMLRequest']="$(Saml::createLogoutRequest)"
    Saml::createRelayState
    tmpSaml['SigAlg']="http://www.w3.org/2000/09/xmldsig#rsa-sha1"

    for key in "${!tmpSaml[@]}"; do
        _query+="$key=$(printf '%s' "${tmpSaml[$key]}" | urlencode.pl)&"
    done

    _query="${_query%&}&Signature=$(Saml::createSignature "SAMLRequest=$( printf '%s' "${tmpSaml['SAMLRequest']}" | urlencode.pl )&RelayState=$(printf '%s' "${tmpSaml['RelayState']}" | urlencode.pl )&SigAlg=$(printf '%s' "${tmpSaml['SigAlg']}" | urlencode.pl)" | urlencode.pl)"

#    _query="${_query%&}&Signature=$(urlencode "$(Saml::createSignature "SAMLRequest=$( urlencode "${tmpSaml['SAMLRequest']}")&RelayState=$(urlencode "${tmpSaml['RelayState']}")&SigAlg=$(urlencode "${tmpSaml['SigAlg']}")")")"

    Session::destroy
    Http::send::cookie "USERNAME=delete; Max-Age=1"

    Http::send::redirect temporary "$(xmlstarlet sel -t -v '//*[name()="SingleLogoutService"]/@Location' ${SAML['idpxml']})?${_query%&}"
}

Saml::validate::LogoutRequest(){
    [private] xmlData="$(printf "${POST['SAMLRequest']}" | base64 -d)"

    Session::check || { Http::send::redirect temporary "/"; return 1; }

    printf '%s' "$xmlData" | xmlstarlet sel -t -v '//*[name()="LogoutRequest"]' &>/dev/null || return 1

    Saml::validate::Issuer "$xmlData" || return 1
    Saml::validate::NameId "$xmlData" || return 1
    Saml::validate::Sign "$xmlData" "LogoutRequest" || return 1

    echo "haa"

    Saml::build::LogoutResponse

}

Saml::build::LogoutXml(){
    [private] _opts
    [public:assoc] SAMLREQUEST

    Saml::request::id
    Saml::request::issueinstant
    Saml::request::destination

    for key in "${!SAMLREQUEST[@]}"; do
        _opts+=" -u '//*[name()=\"LogoutResponse\"]/@$key' -v \"${SAMLREQUEST[$key]}\""
    done

    _opts+=" -u '//*[name()=\"saml:Issuer\"]' -v \"${SAML['spurl']}\""

    eval "xmlstarlet ed $_opts ${SAML['logoutresponsexml']}"

    unset _opts

}

Saml::createLogoutResponse(){
    Saml::build::LogoutXml | phpdeflate.php -M deflate -s | base64 -w0
}

Saml::build::LogoutResponse(){
    [private] _query
    [private:assoc] tmpSaml

    tmpSaml['SAMLRequest']="$(Saml::createLogoutResponse)"
    Saml::createRelayState
    tmpSaml['SigAlg']="http://www.w3.org/2000/09/xmldsig#rsa-sha1"

    for key in "${!tmpSaml[@]}"; do
        _query+="$key=$(printf '%s' "${tmpSaml[$key]}" | urlencode.pl)&"
    done

    _query="${_query%&}&Signature=$(Saml::createSignature "SAMLRequest=$( printf '%s' "${tmpSaml['SAMLRequest']}" | urlencode.pl )&RelayState=$(printf '%s' "${tmpSaml['RelayState']}" | urlencode.pl )&SigAlg=$(printf '%s' "${tmpSaml['SigAlg']}" | urlencode.pl)" | urlencode.pl)"

#    _query="${_query%&}&Signature=$(urlencode "$(Saml::createSignature "SAMLRequest=$( urlencode "${tmpSaml['SAMLRequest']}")&RelayState=$(urlencode "${tmpSaml['RelayState']}")&SigAlg=$(urlencode "${tmpSaml['SigAlg']}")")")"

    Session::destroy
    Http::send::cookie "USERNAME=delete; Max-Age=1"

    Http::send::redirect temporary "$(xmlstarlet sel -t -v '//*[name()="SingleLogoutService"]/@Location' ${SAML['idpxml']})?${_query%&}"
}

alias saml::idGen='Saml::idGen'
alias saml::request::id='Saml::request::id'
alias saml::request::assertion='Saml::request::assertion'
alias saml::request::issueinstant='Saml::request::issueinstant'
alias saml::request::destination='Saml::request::destination'
alias saml::buildXmlFile='Saml::buildXmlFile'
alias saml::createRelayState='Saml::createRelayState'
alias saml::createSamlRequest='Saml::createSamlRequest'
alias saml::createSignature='Saml::createSignature'
alias saml::buildAuthnRequest='Saml::buildAuthnRequest'
alias saml::validate::Issuer='Saml::validate::Issuer'
alias saml::validate::Sign='Saml::validate::Sign'
alias saml::get::Assertion='Saml::get::Assertion'
alias saml::retrieve::Identity='Saml::retrieve::Identity'

