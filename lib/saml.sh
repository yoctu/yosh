declare -A SAML

function saml::idGen ()
{
    echo "$(uuidgen)"
}

function saml::request::id ()
{
    SAMLREQUEST['ID']="$(saml::idGen)"
}

function saml::request::assertion ()
{
    ! [[ -z "$_saml_host_url" ]] && SAMLREQUEST['AssertionConsumerServiceURL']="${_saml_host_url%/}/acs"
}

function saml::request::issueinstant ()
{
    SAMLREQUEST['IssueInstant']="$(date +%Y-%m-%dT%H:%M:%SZ)"
}

function saml::request::destination ()
{
    SAMLREQUEST['Destination']="$(xmlstarlet sel -t -v '//*[name()="SingleSignOnService"]/@Location' $_saml_idp_xml)"
}

function saml::buildXmlFile ()
{
    local _opts tmpFile="$(mktemp -d)"
    declare -A SAMLREQUEST

    saml::request::id
    saml::request::assertion
    saml::request::issueinstant
    saml::request::destination

    for key in "${!SAMLREQUEST[@]}"
    do
        _opts+=" -u '//*[name()=\"AuthnRequest\"]/@$key' -v \"${SAMLREQUEST[$key]}\""
    done
    
    _opts+=" -u '//*[name()=\"saml:Issuer\"]' -v \"${_saml_host_url%/}\""

    eval xmlstarlet ed $_opts $_saml_xml_template

    unset _opts
}

function saml::createRelayState ()
{
    SAML['RelayState']="$(saml::idGen)"
}

function saml::createSamlRequest ()
{
    saml::buildXmlFile | phpdeflate.php -M deflate -s | base64 -w0
}

function saml::createSignature ()
{   
    local _query_string="$@" tmpQueryFile="$(mktemp)"

    echo -n "$_query_string" | openssl dgst -sha1 -sign "$_saml_priv_key" | base64 -w0
}

function saml::buildAuthnRequest ()
{
    local _query

    if session::check
    then
        http::send::redirect temporary /
        return
    fi

    SAML['SAMLRequest']="$(saml::createSamlRequest)"
    saml::createRelayState
    SAML['SigAlg']="http://www.w3.org/2000/09/xmldsig#rsa-sha1"

    for key in "${!SAML[@]}"
    do
        _query+="$key=$(url_encode ${SAML[$key]})&"
    done

    _query="${_query%&}&Signature=$(url_encode "$(saml::createSignature "SAMLRequest=$( url_encode "${SAML['SAMLRequest']}")&RelayState=$(url_encode "${SAML['RelayState']}")&SigAlg=$(url_encode "${SAML['SigAlg']}")")")"


    http::send::redirect temporary "$(xmlstarlet sel -t -v '//*[name()="SingleSignOnService"]/@Location' $_saml_idp_xml)?${_query%&}"

}


function saml::validate::Issuer ()
{
    local xmlResponse="$1" idpIssuer responseIssuer

    responseIssuer="$(echo "$xmlResponse" | xmlstarlet sel -t -v '//*[name()="saml:Issuer"]')"
    idpIssuer="$(xmlstarlet sel -t -v '//*[name()="SingleSignOnService"]/@Location' $_saml_idp_xml)"
    idpIssuer="${idpIssuer//\/sso/}"

    [[ "$responseIssuer" == "$idpIssuer" ]] || return 1
}

function saml::validate::Sign ()
{
    local xmlResponse="$1" xmlCert xmlSigned xmltoCheck result tmpXmlFile="$(mktemp)" tmpCert="$(mktemp)"

    echo "$xmlResponse" > $tmpXmlFile

   echo "-----BEGIN CERTIFICATE-----\n$(echo "$xmlResponse" | xmlstarlet sel -t -v '//*[name()="ds:X509Certificate"]')\n-----END CERTIFICATE-----" > $tmpCert

    xmlsec1 verify --id-attr:ID "urn:oasis:names:tc:SAML:2.0:protocol:Response" --pubkey-cert-pem $tmpCert $tmpXmlFile &>/dev/null | return 1

    rm $tmpXmlFile
    rm $tmpCert

}

function saml::get::Assertion ()
{
    local xmlResponse="$1"

    echo "$xmlResponse" | xmlstarlet sel -t -v '//*[name()="AttributeStatement"]/*[name()="Attribute"][@Name="http://schemas.xmlsoap.org/claims/CommonName"]'
}

function saml::retrieve::Identity ()
{
    local xmlResponse username

    xmlResponse="$(url_decode "${POST['SAMLResponse']}" | base64 -d -w0)"

    saml::validate::Issuer "$xmlResponse" || return 1
    saml::validate::Sign "$xmlResponse" || return 1

    username="$(saml::get::Assertion "$xmlResponse")"

    session::start
    session::set USERNAME $username
    session::save

    http::send::redirect temporary /
}

