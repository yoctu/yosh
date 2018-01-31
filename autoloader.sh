for file in /usr/share/yosh/lib/*
do
    source $file
done

for file in /usr/share/yosh/func/*
do
    source $file
done

# Source custom lib's
for file in ${DOCUMENT_ROOT%/}/../lib/*
do
    source $file
done

for file in ${DOCUMENT_ROOT%/}/../func/*
do
    source $file
done

