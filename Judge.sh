#!/bin/bash
cd test
filename="../test.seal"
echo "--------Test using" $filename "--------"
../lexer $filename > tempfile
../lexer_answer $filename > tempfile_answer
diff tempfile tempfile_answer > /dev/null
if [ $? -eq 0 ] ; then
    echo passed
else
    echo NOT passed
fi
rm -f tempfile tempfile_answer
cd ..