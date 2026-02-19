#!/bin/bash

content_dir="letter_content"
successful=()
errors=()

if [ $# -eq 0 ]; then
    # No arguments provided: Find all .tex files in the content directory
    echo "No specific companies provided. Compiling ALL cover letters..."
    for f in "$content_dir"/*.tex; do
        targets+=("$(basename "$f" .tex)")
    done
else
    echo "Compiling cover letters for: $*"
    targets=("$@")
fi

for input_name in "${targets[@]}"
do

    company=$(basename "$input_name" .tex)

    if [ ! -f "$content_dir/$company.tex" ]; then
        echo "------------------------------------------------"
        echo "SKIPPING: $content_dir/$company.tex not found."
        errors+=("$company (File not found)")
        continue
    fi

    latexmk -file-line-error -interaction=nonstopmode -synctex=1 -output-format=pdf -output-directory=../out -jobname="$company" letter.tex > /dev/null 2>&1
    retval=$?

    if [ "$retval" -ne 0 ]; then
      errors+=("$company")
    else
      successful+=("$company")
    fi

    mv ../out/"$company".pdf letters/"cover_letter_$company.pdf"

    rm ../out/"$company".aux ../out/"$company".log ../out/"$company".out ../out/"$company".fdb_latexmk ../out/"$company".fls ../out/"$company".synctex.gz
done

echo ""
echo "### FINISHED ###"
echo "Wrote cover letters for the following companies: "
echo "${successful[@]}"

if [ ${#errors[@]} -ne 0 ]; then
  echo "Got errors for the following companies: "
  echo "${errors[@]}"
fi
