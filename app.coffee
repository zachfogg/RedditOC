# Project: RedditOC
# Author: Zach Fogg - zach.fogg@gmail.com

# jQuery:
ORIGINAL_COMMENTS = ".commentarea > .sitetable > .comment"
CHILD_COMMENTS    = ".child > .sitetable > .comment"
COMMENT_DATA      = ".entry"
DATA_AUTHOR       = ".noncollapsed > .tagline > .author"

# Element meta:
OC_AUTHOR_CLASS     = "OCAuthor"
UNIQUE_COMMENT_ATTR = "data-fullname"

dataTree = (root, brancher) ->
    leaf: root,
    branches: dataTree branch, brancher for branch in brancher root

# Given a list of dataTrees, filter a predicate and map a function over the list
# of leaves that match the root leaf as determined by leafProp. More than one
# copy of the same leaf object may end up in the accumulator, so we extract a
# unique 'signature' from each leaf with leafSig, which we use to ensure that
# collectLeaves returns an array of unique objects, that being a set of leaves.
filterMapRootsInTrees = (f, predicate, leafProp, leafSig, trees) ->
    leaves = []
    for root in trees
        rootLeaves = findAll root, leafProp, leafSig, root
        if predicate rootLeaves
            leaves = leaves.concat rootLeaves

    f leaves
    null

findAll = (branch, property, signature, root) ->
    branchProp = property branch.leaf
    do filterFold = (r = root, acc = [], sigs = {}) ->
        rSig = signature r.leaf
        if not sigs[rSig] and (property r.leaf) is branchProp
            sigs[rSig] = true
            acc.push r.leaf
        filterFold b, acc, sigs for b in r.branches
        acc

# The array of dataTrees that are the comment trees of a Reddit comment thread.
commentTrees = (brancher) ->
    dataTree oc, brancher for oc in ($ ORIGINAL_COMMENTS)

# The element that contains the author of the comment argument.
authOfC = (comment) ->
    (($ comment).children COMMENT_DATA).find DATA_AUTHOR

# The function call that adds the a CSS class to original authors.
filterMapRootsInTrees (

    # Map Function - Add a CSS class.
    (comments) -> ($ authOfC comments).addClass OC_AUTHOR_CLASS),

    # Predicate - Trees where the original author comments again.
    ((comments) -> comments.length > 1),

    # Property - Extract the author's name.
    ((comment) -> (authOfC comment).text()),

    # Signature - Extract a unique attribute.
    ((comment) -> ($ comment).attr UNIQUE_COMMENT_ATTR),

    # Data Tree - Branch from a comment into its child comments.
    (commentTrees (c) -> ($ c).find CHILD_COMMENTS)
