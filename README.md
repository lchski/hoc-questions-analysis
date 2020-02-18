# House of Commons Written Questions



## Background

Written questions are a valuable form of information about the workings of government. Compared to the very constrained back-and-forth of the oral question period, written questions allow MPs to form a detailed question to which the government can provide a detailed response. You can [read about the procedural rules around written questions](https://www.ourcommons.ca/About/OurProcedure/Questions/c_g_questions-e.htm#3) if you want to learn more.



## Assembling the data

The written questions for each parliamentary session are listed in the _Status of House Business_ publication, in “Part III – Written Questions”. For example, [the 42<sup>nd</sup> Parliament, 1<sup>st</sup> session had 2,532 written questions](https://www.ourcommons.ca/DocumentViewer/en/42-1/house/status-business/page-12). The _Status_ index is handy, but the information it provides is limited:

- Question number
- Question asker name, riding
- Question sitting day (hidden in the XML)
- Question date
- Question title/summary

If there are any responses, it lists limited information about them:

- Response sitting day (hidden in the XML)
- Response date
- Type of response (written, verbal, or question withdrawn)
- If a written response, the sessional paper number
- If a verbal response, the day the answer was delivered (to look up in the _Debates_, a.k.a. _Hansard_)

This information is handy for a quick reference! But if we want a more comprehensive picture of written questions, we have to pull information from a few other sources.

This project pulls that information in. In addition to the variables listed above, it draws in the following:

- Full question content (pulling from the _Notice Paper_ for the day a question was put forward, e.g., [the _Notice Paper_ for December 7, 2015, with the first four questions from the 42<sup>nd</sup> Parliament, 1<sup>st</sup> session](https://www.ourcommons.ca/DocumentViewer/en/42-1/house/sitting-4/order-notice/page-11), listed under the “Questions” section)
- For verbal responses, the responder name and response content (pulling from the _Debates_, e.g., [the response to Q-17 in the _Debates_ for January 25, 2016](https://www.ourcommons.ca/DocumentViewer/en/42-1/house/sitting-8/hansard#sob8766785), listed under the “Questions on the Order Paper” section)

Taking advantage of [the XML data offered by the House of Commons](https://www.ourcommons.ca/en/open-data), we can automate this parsing. It’s not perfect—[e.g., there are a few question/response details missing](https://github.com/lchski/parliamentary-questions-analysis/blob/master/scripts/load/update-question-details-from-web.R#L90-L107)—but this goes a long way to building a consolidated list of questions and responses.



## Using this project

If you’d just like to use the data, I’ve saved [the processed data files to their own repo](https://github.com/lchski/hoc-questions-data). The README there explains which file is which—you probably want `questions_and_responses.csv`, as it’s the most processed.

You can download and run the R code from this repo if you’d like. To prime the data, you’ll need to run the following:

```
source("scripts/load/update-questions-responses-from-xml.R")
source("scripts/load/update-question-details-from-web.R")
source("scripts/load/update-verbal-responses-from-web.R")
```

After that, `source("load.R)` should be all you need.

_NB!_ There’s a... very decent chance this is not yet a 100% reproducible repo. I likely have some pre-loaded data or pre-created folders or so on that makes it work on my machine. If you run into any problems, don’t hesitate to [create an issue](https://github.com/lchski/parliamentary-questions-analysis/issues) or [reach out on Twitter](https://twitter.com/lchski).



## Next steps

### Website to view question and answer data

This project and the processed data are both in pretty good shape. A great next step would be to set up a simple interface to the data, to easily peruse the questions and responses. I’ve a [datasette instance](https://github.com/simonw/datasette) in mind, but invite you to run with this however you like. If you do something with it, please [let me know](https://twitter.com/lchski)!


### Sessional papers

This project seems to fill one data gap, but there’s still a bunch of inaccessible information from written questions. Sessional papers are the most detailed form of answer, the “written” answer. They’re also inconvenient to access: [you need to email the Library of Parliament, who will send you a CD with a scanned PDF](https://twitter.com/lchski/status/1225436988754493442).

There was [a push in 2014 to publish sessional papers by default](https://www.cbc.ca/news/politics/thousands-of-pages-of-parliamentary-records-set-to-go-public-1.2645032), but [as of 2018 that was held up by concerns over the legal liability of publishing inacessible PDFs](https://www.parl.ca/DocumentViewer/en/42-1/BILI/meeting-6/evidence).

One idea on my mind is to crowdsource this request process. I’ve already started [storing sessional paper PDFs that I receive](https://github.com/lchski/free-the-data/tree/master/lop/sessional-papers), and invite you to add yours. (If you don’t want to use GitHub, feel free to [send them to me](mailto:lucas@lucascherkewski.com) and I can post them.)
