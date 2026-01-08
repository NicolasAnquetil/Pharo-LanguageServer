# Pharo Language Server

[![Continuous](https://github.com/badetitou/Pharo-LanguageServer/actions/workflows/continuous.yml/badge.svg)](https://github.com/badetitou/Pharo-LanguageServer/actions/workflows/continuous.yml)
[![Pharo 12](https://img.shields.io/badge/Pharo-12-%23aac9ff.svg)](https://github.com/pharo-project/pharo)
[![Moose version](https://img.shields.io/badge/Moose-12-%23aac9ff.svg)](https://github.com/moosetechnology/Moose)
[![Coverage Status](https://coveralls.io/repos/github/badetitou/Pharo-LanguageServer/badge.svg?branch=v5)](https://coveralls.io/github/badetitou/Pharo-LanguageServer?branch=v5)

I am an implementation of the [Language Server Protocol (LSP)](https://microsoft.github.io/language-server-protocol/implementors/servers/) for the [Pharo programming language](https://pharo.org/).
My main goal is to provide a unique interface for several generic IDE to manipulate a Pharo environment.

I am used by the following client extensions:

- [vscode-pharo](https://github.com/badetitou/vscode-pharo)
- [eclipse-pharo](https://github.com/badetitou/eclipse-pharo) *Really only a POC. But you might be interested to have a look at it.*

> If you experiement with other IDE, do not hesitate to contact us in an Issue :)

## Features

As a language server, I accept two Pharo/SmallTalk formats:

- *.st* for smalltalk script (as you can see in a playground).
- *.class.st* for tonel files.

Most of the features are available for both formats.

- Code highlighting
- Hover
- Auto-completion

### Script specific features

- Code formatting

### Tonel specific features

- Saving the file create/update the corresponding class in the image

## Installation

Execute this code in any Pharo10/11 Image

```Smalltalk
Metacello new
  githubUser: 'badetitou' project: 'Pharo-LanguageServer' commitish: 'v5' path: 'src';
  baseline: 'PharoLanguageServer';
  load
```

> Or download a pre-existing image in the [release](https://github.com/badetitou/Pharo-LanguageServer/releases) section.

## Usage

Once you have an image with the project installed, you can run it using

```sh
/path/to/vm/pharo [--headless] /path/to/pls.image st /path/to/run-server.st
```

In above example, we used an another file named `run-server.st` that is used to define the Pharo script that run the code.
You can find the definition of this file for the [vscode extension](https://github.com/badetitou/vscode-pharo/blob/main/res/run-server.st) and for the [eclipse extension](https://github.com/badetitou/eclipse-pharo/blob/main/res/run-server.st).

Basically the file looks like this

```st
| server |
"Stop and reset potential existing instance in the image you start"
PLSServer reset.
"Create a new Language Server"
server := PLSServer new.
"Start the new language server"
server start.
```

By default, the server will start a socket and give you the port of the opened socket in the standard output.
If you want to use standard input/ouput to deal with communication, you can use the folowing option:

```st
server := PLSServer new
  withStdIO: true;
  yourself
```

> This option is less tested and might create bug with Pharo writing to the standard output for other reason

## Design notes


The server should be able to be launched in "stdio" mode easily.
The 'run-server.st' script needs changes to accomodate for that (see also 'withStdIO' below)

Importants points:
- `PLSAbstractServer>>initialize` initialize the variable `withStdIO` (which comes from `TPLPCommon`
- `PLSAbstractServer>>start`:
  - `initializeStreams` which checks `withStdIO` to initialize clientInStream/clientOutStream to Stdio or SocketStream
  - `startAnswerLoop` starts the main loop (client requests and server answers) in a process.

### Processes

There is a main treatment loop process to read request from the client (an IDE) and anwer them.

Requests are each processed in a separate process to give the client a chance to abort a request.

The priority of the various processes should be chosen carefully.
See discussion [https://github.com/badetitou/Pharo-LanguageServer/issues/19](https://github.com/badetitou/Pharo-LanguageServer/issues/19) [https://github.com/badetitou/Pharo-LanguageServer/issues/19](https://github.com/badetitou/Pharo-LanguageServer/issues/19)



### Treatment loop

`startAnswerLoop` loops on:
- read a request: `extractRequestFrom:`
- execute the request and answers: `handleRequest:toClient:`

Note: `extractRequestFrom:` is long and complex because it tries to read a part of the client request (25 characters) first to find out the length of this request ("content-length:...").
Then it read the request (in JSON) which may be all in the characters already read, partly in it, or not at all in it.


`handleRequest:toClient:` receives a JSON request, processes it, and responds on the stream and 2nd argument.

Requests are processed by `handleJSON:` according to the JRPC pattern (processing methods registered by a `<#jrpc:...>` pragma)

The result of the processing is returned to the client by the nethode `sendData:toClient:`, either in `handleRequest:toClient:` itself (sending the return of `handleJSON:`), or directly when the request is processed, or both (see [https://github.com/badetitou/Pharo-LanguageServer/issues/17](https://github.com/badetitou/Pharo-LanguageServer/issues/17)).

In `handleRequest:toClient:`, the request-handling process is stored (`messageProcess:put:`) in a dictionary with the request ID as the key.
When the query is finished, the process is removed from the dictionary.

## Integration with IDEs

All IDEs seem to be natively capable of interacting with an LSP server on stdio.
Having Pharo-LSP in stdio mode should therefore allow for easy integration.

The generic process is to associate a file type with a command launching the Pharo-LCP server (see the command given at the top of this document)

- Eclipse
  - Load the plugin : [https://github.com/eclipse-lsp4e/lsp4e](https://github.com/eclipse-lsp4e/lsp4e)
  - Create a "Launch configuration / External tool configuration" that launches the Pharo LSP image
  - In the "Preferences / Language server" create a mapping of the desired file type (e.g. "Java source file") to the Launch configuration. The file type may already be known, or may need to be created.
- IntelliJ
  - Load extension: [https://plugins.jetbrains.com/plugin/23257-lsp4ij](https://plugins.jetbrains.com/plugin/23257-lsp4ij),
  - Configure it to launch a Pharo-LSP server,  as described in [https://github.com/redhat-developer/lsp4ij/blob/main/docs/UserDefinedLanguageServer.md](https://github.com/redhat-developer/lsp4ij/blob/main/docs/UserDefinedLanguageServer.md) ("New language server")
- Emacs
  - Load plugin: [https://www.gnu.org/software/emacs/manual/html_node/eglot/](https://www.gnu.org/software/emacs/manual/html_node/eglot/)
  - Create a mapping between an emacs "major-mode" corresponding to the language being processed (e.g. "java-mode") and the command that launches the Pharo image
  - This mapping must be done in the `eglot-server-programs` variable which is a list of associations (a dictionary)
- others: VSCode, VIM, ...
