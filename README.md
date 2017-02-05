# desk
```
docker build -t sigcoww/desk:hoge ./
docker run --rm -v $(pwd)/src/:/work sigcoww/desk:hoge /bin/ash -c "review.py review-pdfmaker config.yml pdfcode" | tee artifacts/build.log
PDF_STATUSCODE=`cat src/pdfcode`
```
