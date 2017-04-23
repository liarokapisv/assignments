
%=====================================================================
% assignment.cls
% Provide assignment.cls class
%=====================================================================

%=====================================================================
% Identification
%=====================================================================
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{assignment}[2016/06/04 My Assignment Class]
\LoadClass{report}[12pt]
\RequirePackage{fancyhdr}
\RequirePackage[top=1in,bottom=1in,left=0.7in,right=0.7in]{geometry}
\RequirePackage{graphicx}
\RequirePackage{titlepic}
\RequirePackage{authoraftertitle}
\RequirePackage[utf8]{inputenc}
\RequirePackage[english, greek]{babel}
\RequirePackage[shortlabels, inline]{enumitem}
\RequirePackage{amsmath}
\RequirePackage{amsfonts}

%=====================================================================
% Commands
%=====================================================================
%command definitions
\newcommand{\en}[1]{\textlatin{#1}}

\newcommand{\varclass}{}
\newcommand{\varassignment}{}
\newcommand{\varname}{}
\newcommand{\varam}{} \newcommand{\class}[1]{\renewcommand{\varclass}{{\expandafter\selectlanguage\expandafter{\varlanguage}#1}}} \newcommand{\assignment}[1]{\renewcommand{\varassignment}{{\expandafter\selectlanguage\expandafter{\varlanguage}#1}}}
\newcommand{\name}[1]{\renewcommand{\varname}{{\expandafter\selectlanguage\expandafter{\varlanguage}#1}}}
\newcommand{\am}[1]{\renewcommand{\varam}{{\expandafter\selectlanguage\expandafter{\varlanguage}#1}}}

\newcommand{\cachelanguage}{\let\varlanguage\languagename}
\cachelanguage
\name{Λιαροκάπης Αλέξανδρος}
\am{03114860}

%setting up titlepagςe
\title{\varclass \\
       {\Large \varassignment}}
\author{Ονοματεπώνυμο: \varname \\
        Αριθμός Μητρώου: \varam}
\date{}
\titlepic{\includegraphics[width=0.4\textwidth]{NTUA.png}}

%setting up header/footer formatting
%\pagestyle{fancy}
%\rhead{\varassignment}
%\lhead{\varclass}
%\rhead{{\expandafter\selectlanguage\expandafter{\varlanguage} \today}}
%\cfoot{\thepage}
%\setlength{\headheight}{15pt}

%setting up enumeration formatting
\renewcommand{\textdexiakeraia}{}
\setlist[enumerate]{label=(\alph*), leftmargin=*}

