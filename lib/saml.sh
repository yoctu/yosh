declare -A SAML
SAML['spurl']=""
SAML['xmltemplate']=""
SAML['idpxml']=""
SAML['privkey']=""

Saml::idGen(){
    echo "$(uuidgen)"
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
    local _opts 
    declare -A SAMLREQUEST

    Saml::request::id
    Saml::request::assertion
    Saml::request::issueinstant
    Saml::request::destination

    for key in "${!SAMLREQUEST[@]}"; do
        _opts+=" -u '//*[name()=\"AuthnRequest\"]/@$key' -v \"${SAMLREQUEST[$key]}\""
    done
    
    _opts+=" -u '//*[name()=\"saml:Issuer\"]' -v \"${SAML['spurl']}\""

    eval "xmlstarlet ed $_opts ${SAML['xmltemplate']}"

    unset _opts
}

Saml::createRelayState(){
    tmpSaml['RelayState']="$(Saml::idGen)"
}

Saml::createSamlRequest(){
    Saml::buildXmlFile | phpdeflate.php -M deflate -s | base64 -w0
}

Saml::createSignature(){   
    local _query_string="$*"

    echo -n "$_query_string" | openssl dgst -sha1 -sign "${SAML['privkey']}" | base64 -w0
}

Saml::buildAuthnRequest(){
    local _query
    local -A tmpSaml

    if Session::check
    then
        Http::send::redirect temporary /
        return
    fi

    tmpSaml['SAMLRequest']="$(Saml::createSamlRequest)"
    Saml::createRelayState
    tmpSaml['SigAlg']="http://www.w3.org/2000/09/xmldsig#rsa-sha1"

    for key in "${!tmpSaml[@]}"
    do
        _query+="$key=$(urlencode "${tmpSaml[$key]}")&"
    done

    _query="${_query%&}&Signature=$(urlencode "$(Saml::createSignature "SAMLRequest=$( urlencode "${tmpSaml['SAMLRequest']}")&RelayState=$(urlencode "${tmpSaml['RelayState']}")&SigAlg=$(urlencode "${tmpSaml['SigAlg']}")")")"

    Http::send::redirect temporary "$(xmlstarlet sel -t -v '//*[name()="SingleSignOnService"]/@Location' ${SAML['idpxml']})?${_query%&}"

}


Saml::validate::Issuer(){
    local xmlResponse="$1" idpIssuer responseIssuer

    responseIssuer="$(echo "$xmlResponse" | xmlstarlet sel -t -v '//*[name()="saml:Issuer"]')"
    idpIssuer="$(xmlstarlet sel -t -v '//*[name()="SingleSignOnService"]/@Location' ${SAML['idpxml']})"
    idpIssuer="${idpIssuer//\/sso/}"

    [[ "$responseIssuer" == "$idpIssuer" ]] || return 1
}

Saml::validate::Sign(){
    local xmlResponse="$1" xmlCert xmlSigned xmltoCheck result tmpXmlFile="$(mktemp)" tmpCert="$(mktemp)"

    echo "$xmlResponse" > $tmpXmlFile

    echo "-----BEGIN CERTIFICATE-----\n$(echo "$xmlResponse" | xmlstarlet sel -t -v '//*[name()="ds:X509Certificate"]')\n-----END CERTIFICATE-----" > $tmpCert

    xmlsec1 verify --id-attr:ID "urn:oasis:names:tc:SAML:2.0:protocol:Response" --pubkey-cert-pem $tmpCert $tmpXmlFile &>/dev/null | return 1

    rm $tmpXmlFile
    rm $tmpCert

}

Saml::retrieve::Identity(){
    local xmlResponse username decodedXmlResponse
    local xmlTmpFile="$(mktemp)"

    xmlResponse="$(echo "${POST['SAMLResponse']}" | base64 -d)"

    echo "$xmlResponse" > $xmlTmpFile

    decodedXmlResponse="$(xmlsec1 --decrypt --privkey-pem ${SAML['privkey']})"

    Saml::validate::Issuer "$xmlResponse" || return 1
    Saml::validate::Sign "$xmlResponse" || return 1

    Session::start

    Json::to::array SESSION "$(echo "$decodedXmlResponse" | xmlstarlet sel -t -v '//*[name()="AttributeStatement"]/*[name()="Attribute"][@Name="user_entity"]')"

    Session::set USERNAME ${SESSION['user_name']}
    Session::save

    Http::send::redirect temporary /
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

