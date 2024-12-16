# Property Assesments and Sale in Baltimore

An analysis of sales of real property over the last five years in Baltimore, compared
with assessed prices. This project aims to determine whether there is a systematic
issue with assessments in the state of maryland assigning low values to vacant homes
and property.

## Data Sources

Most of the data used in this project is too large to be uploaded to github.All of
the data except for one table is publicly available with both an API endpoint
and the ability to download through an open data portal. I will provide both for
all of those where it is available in addition to a public repository link where
the extracts used in these analyses are available.

### Baltimore Real Property Information (CC 3.0)

[API Endpoint](https://geodata.baltimorecity.gov/egis/rest/services/CityView/Realproperty_OB/FeatureServer/0)

[Open Data Portal](https://data.baltimorecity.gov/datasets/baltimore::real-property-information-2/about)

[My extract](https://doi.org/10.5281/zenodo.14498393)

### Baltimore Vacant Building Notices (CC 3.0)

This is not available through the Baltimore Open Data portal.

[Available extract](https://doi.org/10.5281/zenodo.14497481)

### Maryland Real Property Information (Public Domain)

[API Endpoint](https://geodata.md.gov/imap/rest/services/PlanningCadastre/MD_ParcelBoundaries/MapServer/0)

[Open Data Portal](https://opendata.maryland.gov/Business-and-Economy/Maryland-Real-Property-Assessments_Hidden-Property/ed4q-f8tm/about_data)

[My extract](https://doi.org/10.5281/zenodo.14498401)

## Analysis Scripts

## Acknowledgements and related projects

## Who am I and how to get in touch

My name is Joshua Spokes, I am a GIS Analyst with the City of Baltimore's Department
of Public Works and an enthusiast property tax nerd. This is an extension of my project
looking at property values in southeast Baltimore (https://github.com/brokenspokes/Southeast_Patterson)
and exploring how property that is underutilized frequently gets a pass on their
property tax bill. I will continue to build more analyses like this in the coming
years as we work towards fairer assessments and taxation in our city and state.

The README should continue with an longer description (using sub-headings to break up text as needed).

For data analysis projects, here are a few key elements to consider including in your README:

- Creator: who are you and why did you make this project? How can people get in touch with you?
- 
- Files and organization: what are the scripts and files in your repository? How are they named and organized?
- Usage: how can another user get your data and reproduce your analysis or code? Are there any restrictions on reuse?
- Acknowledgements and related projects: What work is your project inspired by or building on?

Please add a license to your repository and your README with `usethis::use_mit_license()` or another [usethis license function](https://usethis.r-lib.org/reference/licenses.html).

```{r, eval=FALSE}
# Use this to a MIT License to a project 
usethis::use_mit_license()
```

This template is a plain Markdown file. You can alternatively create a README using a RMarkdown file or a Quarto document that you render to a [GitHub Flavored Markdown](https://quarto.org/docs/output-formats/gfm.html) (GFM) document.

```{r, eval=FALSE}
# Use rmarkdown to render a Rmd README file
rmarkdown::render("README.Rmd", output_format = "md_document")

# Use quarto to render a qmd README file
quarto::quarto_render("README.qmd", "gfm")
```

See [Guide to writing “readme” style metadata](https://data.research.cornell.edu/data-management/sharing/readme/) for more information on documenting reusable data publications.

For more general advice, take a look at [Make a README](https://www.makeareadme.com/).

