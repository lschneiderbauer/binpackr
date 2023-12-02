/*
 * from
 * https://cs.stackexchange.com/questions/108859/bin-packing-first-fit-problem-in-on-log-n-time
 *
 */

#include <iostream>
#include <vector>
#include <list>
#include <algorithm>
#include <cmath>
using namespace std;

void make_base(int L, vector<double> &A, vector<double> &tree)
{
    for (int i = A.size(); i < L; i++)
    {
        A.push_back(1); // New bins will be empty
    }
    for (int i = tree.size(); i < 4 * L + 5; i++)
    {
        tree.push_back(1); // These values will be overwritten by build
    }
}

void build(int node, int start, int end,
           vector<double> &A, vector<double> &tree)
{
    if (start == end)
    {
        tree[node] = A[start];
    }
    else
    {
        int mid = (start + end) / 2;
        build(2 * node + 1, start, mid, A, tree);
        build(2 * node + 2, mid + 1, end, A, tree);
        tree[node] = max(tree[2 * node + 1], tree[2 * node + 2]);
    }
}

void update(int node, int start, int end, int idx, double val,
            vector<double> &A, vector<double> &tree)
{
    if (start == end)
    {
        A[idx] = tree[node] = val;
    }
    else
    {
        int mid = (start + end) / 2;
        if (start <= idx && idx <= mid)
        {
            update(2 * node + 1, start, mid, idx, val, A, tree);
        }
        else
        {
            update(2 * node + 2, mid + 1, end, idx, val, A, tree);
        }
        tree[node] = max(tree[2 * node + 1], tree[2 * node + 2]);
    }
}

int query(int node, int start, int end, double val,
          vector<double> &tree)
{
    if (start == end)
    {
        return (start);
    }
    int mid = (start + end) / 2;
    if (tree[2 * node + 1] >= val || fabs(val - tree[2 * node + 1]) < __DBL_EPSILON__)
    {
        return (query(2 * node + 1, start, mid, val, tree));
    }
    return (query(2 * node + 2, mid + 1, end, val, tree));
}

vector<int> ffd_fast(const vector<double> &items, double cap)
{
    int n_items = items.size();

    int b = 0; // Current number of bins

    vector<int> IBM; // Item->bin matching: IBM[i] = bin of i-th item
    vector<double> A;    // Vector with bin remaining sizes used by segment tree
    vector<double> tree; // Vector with segment tree's values

    // Presort item list in descending order
    vector<int> sInd(n_items);

    for (int i = 0; i < n_items; i++)
    {
        // int n = sInd[i];
        int n = i;
        double item_size = items[n];

        if (tree.empty() || tree[0] < item_size)
        {
            int L;
            if (A.empty())
                L = 1;
            else
                L = 2 * A.size();
            make_base(L, A, tree);
            build(0, 0, A.size() - 1, A, tree);
        }

        int idx = query(0, 0, A.size() - 1, item_size, tree);

        if (idx < b)
        {
            IBM.push_back(idx); // Current item was put in idx-th bin
            update(0, 0, A.size() - 1, idx, A[idx] - item_size, A, tree); // Update segment tree
        }
        else
        {
            IBM.push_back(b); // Current item was put in new bin
            update(0, 0, A.size() - 1, idx, cap - item_size, A, tree); // Update segment tree
            b++;                                                // Increased number of used bins
        }
    }

    return (IBM);
}
