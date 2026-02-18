# PhosMag

PhosMag (**Phos**phoproteomics in _**Mag**naporthe_) is a test app running via R Shinylive environment. It allows visualization and download of quantitative phosphopeptide abundance data generated during early appressorium development in *Magnaporthe oryzae*.

---

## Data Source

Data is derived from [Cruz-Mireles et al. 2023, *Cell*](https://doi.org/10.1016/j.cell.2024.04.007), covering phosphopeptide abundances across biological replicates of the wild-type **Guy11** strain and the **Δ*pmk1*** mutant at multiple time points during appressoria development.

---

## Try It Live

You can access PhosMag without any local installation via the hosted Shinylive interface:

👉 [Launch PhosMag](https://nehasahu486.github.io/PhosMag/)

No setup required. Simply open the link in your browser to get started.

The app may take a few seconds to load initially, but will run quickly once all packages are loaded
---

## How to Use

1. Enter a valid **MGG ID** in the search field (e.g. `MGG_00001`)
2. Select the **type of abundances** to display — Normalized LFQ, Averaged LFQ, or both. Normalized abundances are recommended for most analyses.
3. Select one or more **phosphorylation positions** in the master protein sequence. For clarity, it is recommended to select one position at a time.
4. Click **Submit** to generate the plot.

---

## Output

- An interactive bar chart showing phosphopeptide abundances across time points, faceted by strain and phosphorylation site/modification.
- A summary table of the underlying data in wide format.

---

## Notes

- If a queried MGG ID is not present in the dataset, a warning message will appear in the position selector.
- The module relies on the `long_data.tsv` file loaded at app startup.

## Contact and Support

For questions about this workflow or issues contact:
<neha.sahu.tsl@gmail.com>

------------------------------------------------------------------------

*This workflow was developed for quick access to phosphorylation studies in Magnaporthe oryzae research projects.*
