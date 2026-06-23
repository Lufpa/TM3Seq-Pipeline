import argparse

import pandas as pd


def main(file1, file2, if_SE, output):
    df1 = pd.read_table(file1, index_col=0)
    df2 = pd.read_table(file2, index_col=0)
    df = pd.merge(df1, df2, on="Sample")
    assert df.shape[0] == df2.shape[0] and df.shape[1] == df1.shape[1] + df2.shape[1]
    df_table = pd.DataFrame(index=df.index)
    if if_SE=="True":
        df_table['input_reads'] = df['input_reads'].astype(int)

    elif if_SE=="False":
        df_table['input_read_pairs'] = df['input_read_pairs'].astype(int)
        df_table['forward_only_surviving'] = df['forward_only_surviving'].astype(int)
        df_table['reverse_only_surviving'] = df['reverse_only_surviving'].astype(int)

    df_table['after_trimmed'] = df['surviving'].astype(int)
    df_table['uniquely_mapped'] = df['STAR_mqc-generalstats-star-uniquely_mapped'].astype(int)
    df_table['assigned'] = df['featureCounts_mqc-generalstats-featurecounts-Assigned'].astype(int)
    df_table.to_csv(f'{output}', index=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-m', '--folder', type=str, help='Path to the multiqc folder')
    parser.add_argument('-s', '--if_SE', type=str, help='if single end or paired end reads')
    parser.add_argument('-o', '--output', type=str, help='Path to the output file')

    args = parser.parse_args()
    main(f'{args.folder}/multiqc_general_stats.txt', f'{args.folder}/multiqc_trimmomatic.txt', args.if_SE, args.output)
