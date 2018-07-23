# Auto Load all

for file in /usr/share/yosh/lib/*
do
    source $file
done

for file in /usr/share/yosh/func/*
do
    source $file
done

# Source custom lib's
if ls -A ${DOCUMENT_ROOT%/}/../lib/* &>/dev/null
then
    for file in ${DOCUMENT_ROOT%/}/../lib/*
    do
        source $file
    done
fi

if ls -A ${DOCUMENT_ROOT%/}/../func/* &>/dev/null
then
    for file in ${DOCUMENT_ROOT%/}/../func/*
    do
        source $file
    done
fi

