import argparse
from matplotlib import pyplot as plt
from scipy.cluster.hierarchy import dendrogram, linkage
import os

def retrieve_distances(bin_dist_file):
    bin_distances = {}
    with open(bin_dist_file) as fh:
        # first line is a table header
        bins_list = fh.readline().strip().split("\t")
        for i, bin1_in_pair in enumerate(bins_list):
            matrix_row = fh.readline().strip().split("\t")[1:]
            for j in range(i):
                bin2_in_pair = bins_list[j]
                similarity_value = float(matrix_row[j])
                bin_distances[(bin1_in_pair, bin2_in_pair)] = 1 - similarity_value
    return bin_distances


def plot_dendrogram(bin_distances, output_path, width, height):
    keys = [sorted(k) for k in bin_distances.keys()]
    values = bin_distances.values()
    sorted_keys, distances = zip(*sorted(zip(keys, values)))
    Z = linkage(distances)
    labels = sorted(set([key[0] for key in sorted_keys] + [sorted_keys[-1][-1]]))
    plt.figure(figsize=(width, height))
    dendro = dendrogram(Z, orientation='left', labels=labels,
                        leaf_font_size=16, color_threshold=0)
    plt.xticks(fontsize=14)

    output_folder = os.path.dirname(output_path)
    if not os.path.exists(output_folder):
        os.mkdir(output_folder)

    plt.savefig(output_path, format='png', dpi=300, bbox_inches='tight')
    plt.close()


def main():
    parser = argparse.ArgumentParser(
        description="Create hierarchical clustering dendrogram of bin distance \
                        values calculated as (1 - BinSPreader bin similarity)")
    parser.add_argument("-i", "--input_file", required=True, help="bin_dist.tsv file from BinSPreader output")
    parser.add_argument("-o", "--output_file", required=True, help="Name for the generated plot")
    parser.add_argument("-W", "--width", type=int, metavar="N", default=10,
                        required=False, help="Output picture width (default: 10)")
    parser.add_argument("-H", "--height", type=int, metavar="N", default=13,
                        required=False, help="Output picture height (default: 13)")
    args = parser.parse_args()

    plot_dendrogram(retrieve_distances(args.input_file),
                    args.output_file, args.width, args.height)


if __name__ == "__main__":
    main()
