#!/usr/bin/env python3
import argparse
import matplotlib as mpl
import numpy as np
import os
import shutil
mpl.use('Agg')

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns

from collections import namedtuple
from itertools import accumulate
from scipy.stats import hmean
from ast import literal_eval

BinInfo = namedtuple('BinInfo', ['size', 'len', 'completeness', 'contamination'])
AmberInfo = namedtuple('AmberInfo', ['size', 'len', 'purity_bp', 'purity_seq', 'completeness_seq', 'completeness_bp'])

InfoPredicate = namedtuple('InfoPredicate', ['name', 'pred'])
InfoYFunction = namedtuple('InfoFunction', ['name', 'func', 'reverse'])
InfoXFunction = namedtuple('InfoFunction', ['name', 'func'])


def createparser():
    parser = argparse.ArgumentParser()
    parser.add_argument('--stats', "-s", help="Clustering statistics (separated by ,). \n\
        Takes either a list of checkm bin_stats_ext.tsv files or a list of amber metrics_per_bin.tsv files.")
    parser.add_argument('--labels', "-l", help="Label list")
    parser.add_argument('--name', "-n", help="Sample name")
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--amber", action="store_true")
    group.add_argument("--checkm", action="store_true")
    parser.add_argument('--output', '-o', help="Output directory")
    return parser


def parse_checkm_stats(stats_path):
    bin_to_info = {}
    bin_length_threshold = 50000
    with open(stats_path, "r") as stats_handle:
        for bin_line in stats_handle:
            bin_split = bin_line.strip().split("\t")
            bin_name = bin_split[0]
            raw_bin_info = literal_eval(bin_split[1])
            bin_info = BinInfo(size=raw_bin_info["# scaffolds"], 
                               len=raw_bin_info["Genome size"], 
                               completeness=raw_bin_info["Completeness"], 
                               contamination=raw_bin_info["Contamination"])
            bin_to_info[bin_name] = bin_info
    return bin_to_info


def parse_amber_stats(stats_path):
    bin_to_info = {}
    with open(stats_path, "r") as stats_handle:
        full_stats = pd.read_table(stats_path)
        for index, row in full_stats.iterrows():
            cluster_id = row["Bin ID"]
            info = AmberInfo(size=int(row['Bin size (seq)']), len=int(row['Bin size (bp)']), 
                             purity_bp=float(row['Purity (bp)']), purity_seq=float(row['Purity (seq)']),
                             completeness_bp=float(row['Completeness (bp)']), completeness_seq=float(row['Completeness (seq)']))
            # print(info)
            bin_to_info[cluster_id] = info
    return bin_to_info


def high_quality(info):
    return info.completeness >= 90 and info.contamination <= 10


def get_total_length(bin_to_info, predicate):
    return sum([info.len for info in bin_to_info.values() if predicate(info)])


def lower_format(string):
    return string.lower().replace(" ", "_")


def plot_checkm_stats(sample_name, label_to_bin_to_info, output_path):
    empty_func = lambda info: True
    empty_pred = InfoPredicate(name="Total", pred=empty_func)
    high_qual_pred = InfoPredicate(name="High quality", pred=high_quality)
    stat_path = os.path.join(output_path, "sample_stats.csv")
    predicates = [empty_pred, high_qual_pred]
    with open(stat_path, "w") as stats_handle:
        # stats_handle.write(",".join(["Sample name", "Tool", "Total bins", "Total length", "High quality bins", "High quality length"]) + "\n")
        for label, bin_to_info in label_to_bin_to_info.items():
            current_string = "{},{}".format(sample_name, label)
            #fixme ensure predicate order!
            for predicate in predicates:
                print("{} bins statistics".format(predicate.name))
                total_bins = len([info for info in bin_to_info.values() if predicate.pred(info)])
                print("{} bins for {}".format(total_bins, label))
                total_length = get_total_length(bin_to_info, predicate.pred)
                print("Total length {} for {}".format(total_length, label))
                current_string += ",{},{}".format(total_bins, total_length)
            print("===========================")
            current_string += "\n"
            stats_handle.write(current_string)
    # print("Drawing plots in {}".format(output_path))
    label_to_info = {label: [info for info in bin_to_info.values()] for label, bin_to_info in label_to_bin_to_info.items()}
    #y-functions
    contamination_func = lambda info: min(info.contamination, 100.0)
    completeness_func = lambda info: info.completeness
    f1score_func = lambda info: hmean([1 - min(max(0.001, info.contamination), 100.0) / 100.0, min(max(0.001, info.completeness), 100.0) / 100.0])
    contamination = InfoYFunction(name="Contamination", func=contamination_func, reverse=False)
    completeness = InfoYFunction(name="Completeness", func=completeness_func, reverse=True)
    f1score = InfoYFunction(name="F1 score", func=f1score_func, reverse=True)
    y_functions = [contamination, completeness, f1score]
    #y_functions = [f1score]
    #x-functions
    len_func = lambda info: info.len
    one_func = lambda info: 1
    len_index = InfoXFunction(name="Total length", func=len_func)
    rank_index = InfoXFunction(name="Rank index", func=one_func)
    x_funcions = [len_index, rank_index]
    for x_func in x_funcions:
        for y_func in y_functions:
            plot_cluster_metric(label_to_info, x_func, y_func, output_path)


def plot_amber_stats(sample_name, label_to_bin_to_info, output_path):
    empty_func = lambda info: True
    # empty_pred = InfoPredicate(name="Total", pred=empty_func)
    # high_qual_pred = InfoPredicate(name="High quality", pred=high_quality)
    # stat_path = os.path.join(output_path, "sample_stats.csv")
    # predicates = [empty_pred, high_qual_pred]
    # print("Drawing plots in {}".format(output_path))
    label_to_info = {label: [info for info in bin_to_info.values()] for label, bin_to_info in label_to_bin_to_info.items()}
    #y-functions
    purity_seq_func = lambda info: info.purity_seq
    purity_bp_func = lambda info: info.purity_bp
    completeness_seq_func = lambda info: info.completeness_seq
    completeness_bp_func = lambda info: info.completeness_bp
    f1score_seq_func = lambda info: hmean([min(max(0.000001, info.purity_seq), 1.0), min(max(0.000001, info.completeness_seq), 1.0)])
    f1score_bp_func = lambda info: hmean([min(max(0.000001, info.purity_bp), 1.0), min(max(0.000001, info.completeness_bp), 1.0)])

    purity_seq = InfoYFunction(name="Purity (seq)", func=purity_seq_func, reverse=True)
    completeness_seq = InfoYFunction(name="Completeness (seq)", func=completeness_seq_func, reverse=True)
    purity_bp = InfoYFunction(name="Purity (bp)", func=purity_bp_func, reverse=True)
    completeness_bp = InfoYFunction(name="Completeness (bp)", func=completeness_bp_func, reverse=True)
    f1score_seq = InfoYFunction(name="F1 score", func=f1score_seq_func, reverse=True)
    f1score_bp = InfoYFunction(name="F1 score (bp)", func=f1score_bp_func, reverse=True)
    # y_functions = [purity_seq, completeness_seq, purity_bp, completeness_bp, f1score_seq, f1score_bp]
    y_functions = [f1score_seq, f1score_bp]
    #x-functions
    len_func = lambda info: float(info.len) / float(1000000) 
    one_func = lambda info: 1
    len_index = InfoXFunction(name="Total length (Mbp)", func=len_func)
    rank_index = InfoXFunction(name="Rank index", func=one_func)
    x_funcions = [len_index, rank_index]
    for x_func in x_funcions:
        for y_func in y_functions:
            plot_cluster_metric(label_to_info, x_func, y_func, output_path)


def get_style(tool_name):
    binners = ["metabat2", "metawrap", "vamb", "MetaBat2", "MetaBAT2", "MaxBin2", "VAMB", "MetaWRAP"]
    refiners = ["metacoag", "MetaCoAG"]
    if "BSP" in tool_name:
        return '--'
    elif len(tool_name.split("-")) > 1 or tool_name == "metacoag" or tool_name == "MetaCoAG":
        return ':'
    else:
        return "-"


def plot_cluster_metric(label_to_info, x_function, y_function, output_path):
    for label, info in label_to_info.items():
        data = sorted(info, reverse=y_function.reverse, key=y_function.func)
        x_values = [0] + [x_function.func(el) for el in data]
        x = list(accumulate(x_values))
        if y_function.name == "Completeness":
            y = [100] + [y_function.func(el) for el in data]
        elif y_function.name == "Contamination":
            y = [0] + [y_function.func(el) for el in data]
        else:
            y = [1] + [y_function.func(el) for el in data]
        # print(x)
        # print(y)
        plt.plot(x, y, label=label, linestyle=get_style(label), linewidth=2)
    plt.ylabel(y_function.name, fontsize=14)
    plt.xlabel(x_function.name, fontsize=14)
    if y_function.name != "F1 score":
        plt.ylim([-5,105])
    # plt.title(y_function.name)
    plt.legend(prop={'size': 12}, loc="center left")
    format_str = "png"
    base_outpath = "{}_{}.{}".format(lower_format(y_function.name), lower_format(x_function.name), format_str)
    plt.savefig(os.path.join(output_path, base_outpath), format=format_str, dpi=300)
    plt.close()


parser = createparser()
args = parser.parse_args()
stats_paths = args.stats.strip().split(",")
labels = args.labels.strip().split(",")
sample_name = args.name
output_path = args.output

if not os.path.exists(output_path):
    os.mkdir(output_path)

# assert(len(labels) == len(stats_paths))
# print(stats_paths)
# print(labels)
labels_and_paths = zip(labels, stats_paths)

if args.checkm:
    label_to_bin_to_info = {label: parse_checkm_stats(stats_path) for (label, stats_path) in labels_and_paths}
    plot_checkm_stats(sample_name, label_to_bin_to_info, output_path)
elif args.amber:
    label_to_bin_to_info = {label: parse_amber_stats(stats_path) for (label, stats_path) in labels_and_paths}
    plot_amber_stats(sample_name, label_to_bin_to_info, output_path)
