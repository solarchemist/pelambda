# Import PerkinElmer UV/Vis spectrum file using R

Structure of spectrum files (`.SP` ASCII) from PerkinElmer Lambda900:

```
R1 6 fields
-1
R3 filename (shortened to 8 chars)
R4 start date
R5 start time
R6 end date
R7 end time

#HDR

#GR
R1 x-axis unit
R2 y-axis unit
R5 x-axis start value
R6 x-axis step size
R7 x-axis number of steps

#DATA
```


## Install this package

To use this package, install it from this repo:

```
install.packages("remotes")
remotes::install_github("solarchemist/pelambda")
```

If you encounter bugs or have questions
[please open an issue](https://github.com/solarchemist/pelambda/issues).




## Develop this package

Check out the source code from this repo:
```
git clone https://github.com/solarchemist/pelambda.git
```

I suggest the following package rebuild procedure (in RStudio IDE):

+ Run `devtools::check()` (in the console or via the **Build** pane).
  Should complete with no errors, warnings or notes:
```
── R CMD check results ──────────────────────────────────── pelambda 0.1.0.9000 ────
Duration: 7.2s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔
```

Contributions are welcome, no matter if code, bug reports or suggestions!



## Refs

+ [Ben Perston (2022). PerkinElmer IR data file import tools, MATLAB Central File Exchange](https://se.mathworks.com/matlabcentral/fileexchange/22736-perkinelmer-ir-data-file-import-tools).
+ [Guillaume Lemaitre (2017). Read SP Perkin Elmer IR binary file](https://specio.readthedocs.io/en/latest/auto_examples/reader/plot_read_sp.html).
