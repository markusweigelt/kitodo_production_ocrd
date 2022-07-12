# Kitodo

Open your browser and navigate to http://localhost:8080/kitodo after OCR-D and Kitodo are started.

Enter the user name `testadmin` and the password `test` in the login dialog.

> Note: If it is the first launch of Kitodo.Production,
> then the `Indexing` tab of the system page is displayed,
> because indexing still needs to be done.
> To perform the indexing, click on the button `Create ElasticSearch mapping`.
> After the mapping is created, click on the button `Start indexing` next to
> the `Whole index` label. After a few seconds, the index is created and you
> can navigate to the dashboard by clicking on the Kitodo.Production logo.


#### Execute OCR script step

From the dashboard, navigate to `All processes` by clicking on the button in processes widget,
or use the URL http://localhost:8080/kitodo/pages/processes.jsf?tabIndex=0.

Select process for OCR, and click on `Possible actions` and then on `Execute KitodoScript`.

Type following text in script field:

```
action:runscript stepname:OCR script:OCR
```

... and click on `Execute KitodoScript`.
(This will run the simplistic Tesseract-based default workflow
asynchronously. The process status will change as soon as the job
is finished.)

Watch `docker logs`, or look under the hood with the Monitor.

#### More configuration options
- [Using project-specific OCR Workflows in Kitodo.Production](https://github.com/markusweigelt/kitodo_production_ocrd/wiki/Using-project-specific-OCR-Workflows-in-Kitodo.Production)