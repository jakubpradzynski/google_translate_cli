# Google Translate CLI

&nbsp;

## Description
This app is a Command Line Interface for Google Translations.

## Installation
Add alias for script:
```
alias translate='bash $PWD/google_translate_cli.sh'
```

## Default source and target language
You can set default source and target translations languages by setting environment variables:
```
export TRANSLATION_DEFAULT_SOURCE_LANG=en
export TRANSLATION_DEFAULT_TARGET_LANG=pl
```
When you run translation and not pass arguments **sourceLang** and **targetLang** this environment variables will be used.

## Auto detect source language
By default this option is on so if you don't set **TRANSLATION_DEFAULT_SOURCE_LANG** environment variable
or don't pass **sourceLang** as parameter source language will be auto detected. 

## Parameters
You can run the app with this parameters:
- _--help_ or _-h_: Show help
- _--list_ or _-l_: List available languages
- _--verbose_ or _-v_: Print more details about translation
- _--sourceLang_ or _-s_: Source language
- _--targetLang_ or _-t_: Target language
- _--query_ or _-q_: Query to translate
 
## Available languages
List of all available languages you can see here:
[Available languages](https://cloud.google.com/translate/docs/languages)

