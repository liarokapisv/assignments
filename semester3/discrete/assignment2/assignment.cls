
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

\newcommand{\class}{}
\newcommand{\assignment}{}

%setting up titlepage
\title{\class \\
       {\Large \assignment}}
\author{Ονοματεπώνυμο: Λιαροκάπης Αλέξανδρος \\
        Αριθμός Μητρώου: 03114860}
\date{}
\titlepic{\includegraphics[width=0.4\textwidth]{NTUA.png}}

%setting up header/footer formatting
\pagestyle{fancy}
\chead{\assignment}
\lhead{Λιαροκάπης Αλέξανδρος}
\rhead{\today}
\cfoot{\thepage}
\setlength{\headheight}{15pt}

%setting up enumeration formatting
\renewcommand{\textdexiakeraia}{}
\setlist[enumerate]{label=(\alph*), leftmargin=*}

