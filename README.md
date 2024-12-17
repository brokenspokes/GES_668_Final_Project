

# Property Assesments and Sale in Baltimore

An analysis of sales of real property over the last five years in
Baltimore, compared with assessed prices. This project aims to determine
whether there is a systematic issue with assessments in the state of
maryland assigning low values to vacant homes and property.

## Data Sources

Most of the data used in this project is too large to be uploaded to
github.All of the data except for one table is publicly available with
both an API endpoint and the ability to download through an open data
portal. I will provide both for all of those where it is available in
addition to a public repository link where the extracts used in these
analyses are available.

### Baltimore Real Property Information (CC 3.0)

[API
Endpoint](https://geodata.baltimorecity.gov/egis/rest/services/CityView/Realproperty_OB/FeatureServer/0)

[Open Data
Portal](https://data.baltimorecity.gov/datasets/baltimore::real-property-information-2/about)

[My extract](https://doi.org/10.5281/zenodo.14498393)

### Baltimore Vacant Building Notices (CC 3.0)

This is not available through the Baltimore Open Data portal.

[Available extract](https://doi.org/10.5281/zenodo.14497481)

### Maryland Real Property Information (Public Domain)

[API
Endpoint](https://geodata.md.gov/imap/rest/services/PlanningCadastre/MD_ParcelBoundaries/MapServer/0)

[Open Data
Portal](https://opendata.maryland.gov/Business-and-Economy/Maryland-Real-Property-Assessments_Hidden-Property/ed4q-f8tm/about_data)

[My extract](https://doi.org/10.5281/zenodo.14498401)

### Maryland CAMA Data

[API
Endpoint](https://geodata.md.gov/imap/rest/services/PlanningCadastre/MD_ComputerAssistedMassAppraisal/MapServer)

[My extract](https://doi.org/10.5281/zenodo.14498436)

### Baltimore Neighborhoods

[Open Data
Portal](https://data.baltimorecity.gov/datasets/baltimore::neighborhood-statistical-area-nsa-boundaries/about)

## Analysis Scripts

The Analysis scripts are in the “R” folder and are numbered in the order
described in this readme in addition to being named the same as their
header. RDS objects or OGC geopackages are used as intermediate objects

### Property Identification

This first script brings together the city and state property
information datasets into a more easily usable table. The city and state
real property datasets both have over 100 columns, much of it unneeded
for this analysis. First, we trim the Baltimore dataset and then join it
to the Maryland state set with the BLOCKLOT identifier in order to get
the account ID for each property. Then, we join the CAMA datasets to get
the land use description that we will utilize for categorization.

### Sale Identification

This script focuses on the sales stored in the state real property
dataset. We are first going to take those and pivot them to a long
format in order to get tidy sales data. I was unsure how to approach the
next two steps so I asked for chatGPT assistance. There is an elegant
method for categorizing sales as vacant or non-vacant based on the date
ranges provided in the VBN data with a join.

Next, we assign the assessed Base and Current Cycle values to the three
years they represent. Maryland’s State Department of Assessments and
Taxation works in a three-year cycle. For this, I also had ChatGPT help
in writing a scripted that translated these ranges into long format.

[Conversation with
Assistance](https://chatgpt.com/share/675f4586-a0cc-8010-8570-52b9856d12c8)

The last two chunks of this script represent subjective choices on my
part that affect the analysis. First, I filter out sales where the price
is represented as \$0 or the assessment is represented as \$0. Zero
dollar sales usually represent a transfer of property and have no
bearing on its value, while the assessments are likely in error as every
property has at least some value. Next, I group and combine sales that
are the same date, price, block, and type of sale since these are likely
to be grouped purchases. This is a data quality issue because the state
fails to separate the price paid for individual proeperties when many
are involved in a transfer.

### Sale Analysis

The first two scripts do most of the heavy lifting aside from
identification of sales and the calculation of the price ratio. This
script brings the intermediate tables together to label the sale with a
land use type. We classify properties with the NO_IMPRV marker from the
Baltimore Real Property data and with no land use classification from
the state CAMA data as unimproved sales. Any sales labeled vacant by the
previous script are identified as vacant. Last, any properties labeled
AUTO or WAREHOUSE are likely underperforming properties. Anything else
is classified as a regular sale.

The price ratio is determined as the Assessed Value at the time of sale
divided by the price of the sale. So if it’s over 1, the property is
overassessed and under 1 is underassessed. The second part of this
script splits and summarises the sales, aggregating them by neighborhood
and identifier.

## Visualization Scripts

Frustratingly, after the analysis was completed, we arrive at a point
showing limited interesting insight. The lack of historical assessments
in the public-facing data in addition to the difficulty of identifying
sales where a home might have been substantially renovated before make
the data on vacant sales quite dirty. With the intended deadline for my
project and my grade dependent on submission, I am satisfied with the
work done and always love representing Baltimore in map form even if
it’s not so elegant. I hope that I will be able to continue this work in
the coming years.

### Sale density dotplot

I like using this visualization first because

``` r
source("R/04_sale_dotplot.R")
```

    Linking to GEOS 3.11.0, GDAL 3.5.3, PROJ 9.1.0; sf_use_s2() is TRUE

    ── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
    ✔ dplyr     1.1.4     ✔ readr     2.1.5
    ✔ forcats   1.0.0     ✔ stringr   1.5.1
    ✔ ggplot2   3.5.1     ✔ tibble    3.2.1
    ✔ lubridate 1.9.3     ✔ tidyr     1.3.1
    ✔ purrr     1.0.2     
    ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ✖ dplyr::filter() masks stats::filter()
    ✖ dplyr::lag()    masks stats::lag()
    ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors

    Reading layer `neighborhood_stats' from data source 
      `/Users/jspokes/Documents/R_Projects/Final_Project_Presentation/Data/neighborhood_stats.gpkg' 
      using driver `GPKG'
    Simple feature collection with 279 features and 27 fields
    Geometry type: MULTIPOLYGON
    Dimension:     XY
    Bounding box:  xmin: 1393931 ymin: 557733.6 xmax: 1445504 ymax: 621406.8
    Projected CRS: NAD83 / Maryland (ftUS)

``` r
mapdeck_output
```

![](README_files/figure-commonmark/dotplot-1.png)

## Acknowledgements and related projects

This project was inspired by similar work being taken on elsewhere that
investigates the myriad of ways local governments, inadvertently or not,
punish those with less wealth, less income, or just a smaller business.
My interest in these topics is thanks to [Strong Towns by Charles
Marohn](https://www.strongtowns.org/) and his work bringing attention to
government’s weakened ability to do the basics. Further, companies like
Urban3 and their [Just Accounting
Project](https://www.justaccounting.org/) have shown how this type of
assessment bias can be systematic. Last, [Dr. Christopher Berry’s
project](https://s3.us-east-2.amazonaws.com/propertytaxdata.uchicago.edu/nationwide_reports/web/Baltimore%20city_Maryland.html#5_who_is_over-assessed)
on this type of assessment bias in Baltimore showed how we need to
pursue better policy solutions at home.

## Who am I and how to get in touch

My name is Joshua Spokes, I am a GIS Analyst with the City of
Baltimore’s Department of Public Works and an enthusiast property tax
nerd. This is an extension of my project looking at property values in
southeast Baltimore
(https://github.com/brokenspokes/Southeast_Patterson) and exploring how
property that is underutilized frequently gets a pass on their property
tax bill. I will continue to build more analyses like this in the coming
years as we work towards fairer assessments and taxation in our city and
state.

The README should continue with an longer description (using
sub-headings to break up text as needed).

For data analysis projects, here are a few key elements to consider
including in your README:

- Creator: who are you and why did you make this project? How can people
  get in touch with you?
- 
- Files and organization: what are the scripts and files in your
  repository? How are they named and organized?
- Usage: how can another user get your data and reproduce your analysis
  or code? Are there any restrictions on reuse?
- Acknowledgements and related projects: What work is your project
  inspired by or building on?

Please add a license to your repository and your README with
`usethis::use_mit_license()` or another [usethis license
function](https://usethis.r-lib.org/reference/licenses.html).

``` r
# Use this to a MIT License to a project 
usethis::use_mit_license()
```

    ✔ Setting active project to
      "/Users/jspokes/Documents/R_Projects/Final_Project_Presentation".

This template is a plain Markdown file. You can alternatively create a
README using a RMarkdown file or a Quarto document that you render to a
[GitHub Flavored
Markdown](https://quarto.org/docs/output-formats/gfm.html) (GFM)
document.

``` r
# Use quarto to render a qmd README file
quarto::quarto_render("README.qmd", "gfm")
```

See [Guide to writing “readme” style
metadata](https://data.research.cornell.edu/data-management/sharing/readme/)
for more information on documenting reusable data publications.

For more general advice, take a look at [Make a
README](https://www.makeareadme.com/).
