/*
 * code is inspired from a stack exchange answer from George Vidalakis,
 * https://cs.stackexchange.com/questions/108859/bin-packing-first-fit-problem-in-on-log-n-time
 * and modified as required.
 */
#include <vector>
#include <cmath>
using namespace std;

void make_base(vector<double>::size_type L,
               vector<double> &A, vector<double> &tree, double cap)
{
    A.reserve(L);
    tree.reserve(4 * L + 5);

    for (vector<double>::size_type i = A.size(); i < L; i++)
    {
        A.push_back(cap); // New bins will be empty
    }
    for (vector<double>::size_type i = tree.size(); i < 4 * L + 5; i++)
    {
        tree.push_back(cap); // These values will be overwritten by build
    }
}

void build(vector<double>::size_type node,
           vector<double>::size_type start,
           vector<double>::size_type end,
           vector<double> &A, vector<double> &tree)
{

    if (start == end)
    {
        tree[node] = A[start];
    }
    else
    {
        vector<double>::size_type mid = (start + end) / 2;

        build(2 * node + 1, start, mid, A, tree);
        build(2 * node + 2, mid + 1, end, A, tree);
        tree[node] = max(tree[2 * node + 1], tree[2 * node + 2]);
    }
}

void update(vector<double>::size_type node,
            vector<double>::size_type start,
            vector<double>::size_type end,
            vector<double>::size_type idx,
            double val,
            vector<double> &A, vector<double> &tree)
{

    if (start == end)
    {
        A[idx] = tree[node] = val;
    }
    else
    {
        vector<double>::size_type mid = (start + end) / 2;
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

vector<double>::size_type query(vector<double>::size_type node,
                                vector<double>::size_type start,
                                vector<double>::size_type end,
                                double val,
          vector<double> &tree)
{
    if (start == end)
    {
        return (start);
    }
    vector<double>::size_type mid = (start + end) / 2;
    if (tree[2 * node + 1] >= val - __DBL_EPSILON__)
    {
        return (query(2 * node + 1, start, mid, val, tree));
    }
    return (query(2 * node + 2, mid + 1, end, val, tree));
}

vector<vector<double>::size_type> ffd_fast(const vector<double> &items, double cap)
{
    vector<double>::size_type n_items = items.size();

    vector<double>::size_type b = 0; // Current number of bins

    vector<vector<double>::size_type> IBM; // Item->bin matching: IBM[i] = bin of i-th item
    vector<double> A;    // Vector with bin remaining sizes used by segment tree
    vector<double> tree; // Vector with segment tree's values

    for (vector<double>::size_type i = 0; i < n_items; i++)
    {
        // in case the item size is greater then cap
        // just pretend it is equal the full capacity
        double item_size = min(cap, items[i]);

        if (tree.empty() || tree[0] < item_size)
        {
            vector<double>::size_type L;
            if (A.empty())
                L = 1;
            else
                L = 2 * A.size();
            make_base(L, A, tree, cap);
            build(0, 0, A.size() - 1, A, tree);
        }

        vector<double>::size_type idx =
          min(b, query(0, 0, A.size() - 1, item_size, tree));

        IBM.push_back(idx); // Current item was put in idx-th bin
        update(0, 0, A.size() - 1, idx, A[idx] - item_size, A, tree); // Update segment tree


        if (idx >= b)
        {
            b++; // Increased number of used bins
        }
    }

    return (IBM);
}
