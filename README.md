# READMISSION RISK USING PARR-30

Unplanned hospital admissions and readmissions increase the cost of healthcare and are markers of suboptimal care; t is a priority to avoid them. In 2012, Bilings J, Blunt I et al. at Nuffield Trust built a predictive model to estimate the risk and costs of re-admission to an NHS hospital in England within 30 days of discharge. This Patients at Risk of Re-hospitalisation within 30 days (PARR-30) predictive model classified the patients as being low, medium or high risk of being readmitted.

This RShiny mini-app is a visualisation tool that shows the predicted classification of 200 patients from a synthetic sample dataset created by Aridhia. The patients in this sample data are children at risk of severe asthma exacerbations.Using this sample data, we calculated the predicted risk of readmission within 30 days using the default original PARR-30 coefficients. As the real outcome of each of these patients is known, it allows for comparison with the predicted model. 

For more information you can read our blog post on this app: https://www.aridhia.com/blog/parr-30-mini-app/.

The paper explaining the development of the PARR-30 model can be found here: https://bmjopen.bmj.com/content/2/4/e001667

#### Checkout and run

You can clone this repository by using the command:

```
git clone https://github.com/aridhia/demo-intervention-studies
```

Open the .Rproj file in RStudio and use `runApp()` to start the app.

### Deploying to the workspace

1. Download this GitHub repo as a .zip file.
2. Create a new blank Shiny app in your workspace called "intervention-studies".
3. Navigate to the `intervention-studies` folder under "files".
4. Delete the `app.R` file from the `intervention-studies` folder. Make sure you keep the `.version` file!
5. Upload the .zip file to the `intervention-studies` folder.
6. Extract the .zip file. Make sure "Folder name" is blank and "Remove compressed file after extracting" is ticked.
7. Navigate into the unzipped folder.
8. Select all content of the unzipped folder, and move it to the `intervention-studies` folder (so, one level up).
9. Delete the now empty unzipped folder.
10. Start the R console and run the `dependencies.R` script to install all R packages that the app requires.
11. Run the app in your workspace.

For more information visit https://knowledgebase.aridhia.io/article/how-to-upload-your-mini-app/




