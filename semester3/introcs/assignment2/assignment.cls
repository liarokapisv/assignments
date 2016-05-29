
%=====================================================================
% assignment.cls
% Provide assignment.cls class
%=====================================================================

%=====================================================================
% Identification
%=====================================================================
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{assignment}[2009/02/11 Homework Class]
\LoadClass[12pt]{report}
\RequirePackage{fancyhdr}
\RequirePackage[top=1in,bottom=1in,left=0.7in,right=0.7in]{geometry}
\RequirePackage{graphicx}
%\RequirePackage{empheq}
\RequirePackage{ifthen}
\RequirePackage{titlepic}
\RequirePackage{authoraftertitle}
\RequirePackage[utf8]{inputenc}
\RequirePackage[greek, english]{babel}
%=====================================================================
% Commands
%=====================================================================

\author{\textgreek{Λιαροκάπης Αλέξανδρος (03114860)}}
\date{}
\titlepic{\includegraphics[width=0.8\textwidth]{NTUA.png}}
\pagestyle{fancy}
\fancyhf{}% Clear header/footer
\chead{\MyTitle}
\cfoot{\thepage}
\setlength{\headheight}{15pt} 



% Set up counters for problems and subsections

\newcounter{ProblemNum}
\newcounter{SubProblemNum}[ProblemNum]

\renewcommand{\theProblemNum}{\arabic{ProblemNum}}
\renewcommand{\theSubProblemNum}{\alph{SubProblemNum}}

 \newcommand*{\prob}[1]{\newpage\subsection*{#1} }
 \newcommand*{\cprob}[1]{\stepcounter{ProblemNum} %
 \prob{Problem \theProblemNum. \; #1}}
 \newcommand*{\soln}[1]{\subsubsection*{#1}}
 \newcommand*{\solution}{\soln{\textgreek{Λύση}}}
 \renewcommand*{\part}[1]{\soln{\textgreek{Μέρος} (#1)}}
 \newcommand*{\cpart}{\stepcounter{SubProblemNum} %
 \soln{Μέρος (\theSubProblemNum)}}
 
 \renewcommand{\theenumi}{(\alph{enumi})}
 \renewcommand{\labelenumi}{\theenumi}
 \renewcommand{\theenumii}{\roman{enumii}}

\renewcommand{\textdexiakeraia}{}
\renewcommand{\textstigma}{\textsigma\texttau}

