# setopt functions we need
shopt -s extglob
shopt -s nullglob
shopt -s expand_aliases

# Auto Load all
for file in ${YOSH_PATH}/{lib,func,auth,session,config}/*.sh; do
    source $file
done

for file in ${YOSH_PATH}/package/*/{lib,func,auth,session,config}/*.sh; do
    source $file
done

# Source custom lib's


[[ -z "$DOCUMENT_ROOT" ]] || for file in ${DOCUMENT_ROOT%/}/../{lib,func,auth,session,config}/*.sh; do
    source $file
done


# Packaging system
# Lib Files for packaging system
[[ -z "$DOCUMENT_ROOT" ]] || for file in ${DOCUMENT_ROOT%/}/../package/*/{lib,func,auth,session,config}/*.sh; do
    source $file
done

[[ -z "$DOCUMENT_ROOT" ]] || for file in ${etc_conf_dir%/}/*.sh; do
    source $file
done

