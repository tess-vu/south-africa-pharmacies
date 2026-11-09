from __future__ import annotations

from pathlib import Path
from typing import List, Union, Optional

import pandas as pd


def pdf_tables_to_dfs(
    pdf_path: Union[str, Path],
    pages: str = "all",
    flavor: str = "auto",
    guess: bool = True,
    strip_text: str = "\n",
) -> List[pd.DataFrame]:
    """
    Extract tables from a PDF and return them as a list of pandas DataFrames.

    Parameters
    ----------
    pdf_path : str | Path
        Path to the PDF file.
    pages : str
        Page selection in Camelot format, e.g. "1", "1-3", "1,3,5-7", or "all".
    flavor : {"auto","lattice","stream"}
        - "lattice": best for tables with visible ruling lines
        - "stream": best for whitespace/aligned-text tables
        - "auto": try lattice first; if no tables found, try stream
    guess : bool
        Let Camelot guess table areas.
    strip_text : str
        Characters to strip from extracted cell text (often "\\n" helps).

    Returns
    -------
    List[pd.DataFrame]
        A list of extracted tables as DataFrames (may be empty if none found).
    """
    pdf_path = Path(pdf_path)
    if not pdf_path.exists():
        raise FileNotFoundError(f"PDF not found: {pdf_path}")

    try:
        import camelot  # type: ignore
    except ImportError as e:
        raise ImportError(
            "camelot is not installed. Install with:\n"
            "  pip install camelot-py\n"
            "For 'lattice' you may also need Ghostscript installed (esp. on Windows)."
        ) from e

    def _read(fl: str):
        return camelot.read_pdf(
            str(pdf_path),
            pages=pages,
            flavor=fl,
            guess=guess,
            strip_text=strip_text,
        )

    if flavor == "auto":
        tables = _read("lattice")
        if len(tables) == 0:
            tables = _read("stream")
    elif flavor in {"lattice", "stream"}:
        tables = _read(flavor)
    else:
        raise ValueError("flavor must be one of: 'auto', 'lattice', 'stream'")

    dfs: List[pd.DataFrame] = []
    for t in tables:
        df = t.df.copy()

        # light cleanup: normalize empty strings to NA, then drop fully empty rows/cols
        df = df.replace(r"^\s*$", pd.NA, regex=True)
        df = df.dropna(how="all")
        df = df.loc[:, ~df.isna().all()]

        dfs.append(df)

    return dfs
