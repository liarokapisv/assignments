
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

\newenvironment{gathered*}
{\hfill $ \gathered[t] \displaystyle}
{\endgathered $ \hfill\null}

\newenvironment{aligned*}
{\hfill $ \aligned[t] \displaystyle}
{\endaligned $ \hfill\null}

%==========================================================
% Problem Environment
%============================================================

\newcounter{questioncounter}
\setcounter{questioncounter}{1}

\newenvironment{questions}
{\begin{enumerate}}
{\end{enumerate}}


\newenvironment{answers}
{\begin{enumerate}}
{\end{enumerate}}


\newcommand{\question}[1]{%
\global\expandafter\def\csname questionarray\the\value{questioncounter} \endcsname{#1}%
\stepcounter{questioncounter}%
\item[(#1)]%
}

\newcommand{\answer}{%
\item[(\csname questionarray\the\value{questioncounter} \endcsname)\stepcounter{questioncounter}]%
}

\newcommand{\problem}[1]{%
\setcounter{questioncounter}{1}%
\newpage\subsection*{#1}%
}

\newcommand{\solution}{%
\setcounter{questioncounter}{1}%
\subsubsection*{Λύση}%
}


%=======================================================
%setting up titlepage
%=============================================================

\newcommand{\assignment}{}
\newcommand{\createtitle}[2]{%
\renewcommand{\assignment}{#2}
\title{{#1}\\
       {\Large \assignment}}
\author{Ονοματεπώνυμο: Λιαροκάπης Αλέξανδρος \\
        Αριθμός Μητρώου: 03114860}
\date{}
\titlepic{\includegraphics[width=0.4\textwidth]{NTUA.png}}
\maketitle
}

%setting up header/footer formatting
\pagestyle{fancy}
\chead{\assignment}
\lhead{Λιαροκάπης Αλέξανδρος}
\rhead{\today}
\cfoot{\thepage}
\setlength{\headheight}{15pt}

%setting up enumeration formatting
\renewcommand{\textdexiakeraia}{}
\setlist[enumerate, 1]{label=(\arabic*), leftmargin=*}
