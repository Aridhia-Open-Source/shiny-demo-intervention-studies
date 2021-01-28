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

#### Deploying to the workspace

1. Create a new mini-app in the workspace called "intervention-studies"" and delete the folder created for it
2. Download this GitHub repo as a .ZIP file, or zip all the files
3. Upload the .ZIP file to the workspace and upzip it inside a folder called "intervention-studies"
4. Run the app in your workspace




