# Clinical-Text-Mining

## Overview

 A project focuses on mining potential knowledge from clinical text, based on database [UMLS](https://www.nlm.nih.gov/research/umls/),
   [StanfordNLP](http://nlp.stanford.edu/)/[OpenNLP](https://opennlp.apache.org/) and platform [Apcache Spark](http://spark.apache.org/).
 
## Features
### General text processing
 We call it "general" because anytime given a text dataset, we have to transform the text into
 the form that we can process them, usually it can be a vector of words.
 Currently, we use Apache openNLP or StanfordNLP (based on the configuration; we recommend to use StanfordNLP to process the text,
 including sentence detection, tokenization and  Part-of-Speech parsing.
 We use Lexical Variant Generation (LVG) to convert the variant of a word to its basic form.
 We use a user-defined stop word list to filter out the meaningless words. Note that a term contains
 more than one word, we will filter out it if it begins or ends with a stop word.

### Term identification (fuzzy matching)
 Term identification is a feature that given some texts and a list of term, we identify if the term 
 occurs in the text.
 To put it simply, Clinical-Text-Mining includes steps:

 - For the list of tems, we do the same general process, also remove stop words, normalization and
   resort the order of ther words in the terms, to get the basic form of the term, then store the result in Mysql (or solr)
 - For the texts, applay the general process mentioned above, then we obtain a vector of words for every
   text also the syntax information of the text.  
 - We construct [N-gram](https://en.wikipedia.org/wiki/N-gram) from the vector of the texts and also 
   find its basic for as above description, and then match the Ngram to check if it is found in the term list stored in Mysql (or solr).
 - For a N-gram, it may match more than one term in the list. We will give a similarity score based on
   the [Levenshtein distance](https://en.wikipedia.org/wiki/Levenshtein_distance), and we also collecting
   other information about the term, such as the semantic type if it is a term in UMLS.

## Prepare to run
1. Download this project use: `git clone https://github.com/zwChan/Clinical-Text-Mining.git`. I recommend
   to use an IDE such as IDEA.  It is a maven project, so it should be easy to build it.
   Add an environment variable `CTM_ROOT_PATH`, which indicates the root directory of the project. 
   The tool will find the configuration file and resource file in the project directory.
2. Add the dependency package int `libs` directory to the project, see file ( docs/dependency-package.jpg),
   and set the environment variable `CTM_ROOT_PATH` to be the root directory of the project. The program will
   look for configuration file and other resource files (e.g. stopwords.txt) based on this root directory.
3. **Prepare the UMLS data for test**. **(This step may take lots of time)**
   You can follow the Sujit's post [Understanding UMLS](http://sujitpal.blogspot.com/2014/01/understanding-umls.html)
   or the [documentation of UMLS](http://www.nlm.nih.gov/research/umls/new_users/online_learning/OVR_001.html).
   At the end, you will import the UMLS data into Mysql.
4. Build index database for fuzzy matching.
   Run the test function: com.votors.umls.UmlsTagger2Test.testBuildIndex2db, or
   run `java -cp Clinical-Text-Mining-0.0.1-SNAPSHOT-jar-with-dependencies.jar:/data/ra/stanford-corenlp-3.6.0-models.jar  com.votors.umls.BuildTargetTerm` in terminal.
   and it will create a index table from UMLS database

5. (Instead of using Mysql, use Solr for fuzzy matching. More complicated but faster, not recommended)
   Then export the test data  using sql:
   ```
    select a.cui,a.aui,a.sab,a.str,b.str from mrconso a, mrconso b
    where a.cui=b.cui and b.TS='P' and b.STT='PF' and b.ISPREF='Y' and a.lat = 'ENG' and a.lat = 'ENG'
        limit 10000  -- No limit if you want to use all the umls terms
        into outfile 'your-path/first_10000.csv'
        fields terminated by ','
        enclosed by '"' lines
        terminated by '\n';
   ```
   Configure the jdbc of you Mysql in configuration file (conf\default.properties), then
   run `java -cp Clinical-Text-Mining-0.0.1-SNAPSHOT-jar-with-dependencies.jar:/data/ra/stanford-corenlp-3.6.0-models.jar  com.votors.umls.BuildTargetJson4solr your-path/first_10000.csv your-path/first_10000.json`
   in terminal.

   
6. Good luck and enjoy it!

## Run by projects
### CHV paper
#### Overview

 A project focus on recommendation of CHV terms from social media, based on dataset [UMLS](https://www.nlm.nih.gov/research/umls/)
   and platform [Apcache Spark](http://spark.apache.org/). The analyzed dataset is Yahoo!Answers corpus about diabetes and cancer.
 Conceptual idea is shwon in flowing figure.
 ![Conceptual idea](docs/figurs/conceptual.png)

#### Methodology introduction
- We first extract n-gram from Yahoo!Answers textual dataset (of course, you can
 use any other textual dataset);
- Second, identify the CHV terms using fuzzy matching method with UMLS database. We also call these terms as seed terms.
   The other terms which do not match with any CHV term is considered as candidate terms.
- Third, we use K-means algorithm to train a model from the identified CHV terms, and we get K centers for the model..
- Fourth, we calculate the distance between a candidate term to all the K centers, and we choose the shortest distance
  as the score to measure whether we should recommend a term as a CHV term. The smaller the score is, the more likely a candidate
  term should considered as a CHV term.

 The workflow of the project is shown in following figure.
 ![workflow](docs/figurs/work-flow.png)
#### Run for the result
you can run the class `com.votors.ml.Clustering` in the IDEA directly. You probably need to set the maximum memory larger: -Xmx5000m
or submit it to Spark cluster:
```
spark-submit --master spark://128.186.72.242:7077  --deploy-mode cluster --num-executors 9 --driver-memory 10g  --executor-memory 2048m
 --executor-cores 1  --class com.votors.ml.Clustering  --conf 'spark.executor.extraJavaOptions=-DCTM_ROOT_PATH=/data/ra/Clinical-Text-Mining
 -cp /data/ra/stanford-corenlp-3.6.0-models.jar:/usr/bin/spark/spark-run/conf/:/usr/bin/spark/spark-run/lib/spark-assembly-1.6.0-hadoop2.6.0.jar:/usr/bin/spark/spark-run/lib/datanucleus-core-3.2.10.jar:/usr/bin/spark/spark-run/lib/datanucleus-rdbms-3.2.9.jar:/usr/bin/spark/spark-run/lib/datanucleus-api-jdo-3.2.6.jar'
 --driver-java-options=-DCTM_ROOT_PATH=/data/ra/Clinical-Text-Mining
 --files /data/ra/Clinical-Text-Mining/conf/default.properties,/data/ra/Clinical-Text-Mining/conf/current.properties
 /data/ra/Clinical-Text-Mining/target/Clinical-Text-Mining-0.0.1-SNAPSHOT-jar-with-dependencies.jar > result_yahoo_rank.txt 2>spark.log
```

#### Result figures
**Evaluation:**
 ![Evaluation](/docs/figurs/evaluation_simiterm.png)

**Human review result:**
 ![human review](docs/figurs/figure8_human_review.png)

### BIBM(2016) paper
A project focuses on analyzing temporal context of clinical trials from [Clinicaltrials](https://clinicaltrials.gov/).

#### Run for the result
Run class `com.votors.umls.AnalyzeCT` in IDEA with parameter (you maybe have to look at the code a little bit):
pattern C:\fsu\ra\data\201601\split_criteria\ 1308_colorectal_trials_criteria_0413 criteriaWords cancer

#### Result figures
**Semantic type distribution**
 ![sty_distribution](/docs/figurs/sty_distribution.png)

**Temporal context heatmap**
 ![temporal_context_heatmap](/docs/figurs/cui_duration_heatmap3.png)


## Dependency
 - UMLS data


## Contributor
  Anyone interested in the project is welcome!