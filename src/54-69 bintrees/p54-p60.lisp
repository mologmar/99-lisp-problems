;;;; Constructing binary trees

(in-package #:99-lisp-problems)

;;; In Lisp we represent the empty tree by 'nil' and the non-empty tree by the list (X L R), 
;;;   where X denotes the root node and L and R denote the left and right subtree, respectively. 
;;; The example tree depicted opposite is therefore represented by the following list: 
;;;   (a (b (d nil nil) (e nil nil)) (c nil (f (g nil nil) nil))) 
;;; Other examples are a binary tree that consists of a root node only:
;;;   (a nil nil) or an empty binary tree: nil.

;;; p54

(defun tree-p (tree)
  "Return T if the argument represents a valid binary tree."
  (or (null tree)
      (and (listp tree)
           (= (length tree) 2)
           (tree-p (second tree))
           (tree-p (third tree)))))

;;; p55

(defun cbal-trees (n)
  "Construct all possible completely balanced trees, i.e. trees for whose every node the difference of the number of nodes
for each subtree is at most 1, with N nodes in total, all containing the symbol X as its value."
  (when (> n 0)
    (reduce #'union (mapcar #'gen-cbal-trees (cbal-trees (1- n))))))

(defun gen-cbal-trees (tree &aux (sym 'X))
  "Generate all completely balanced trees that can be reached by adding a node to the leaves of TREE."
  (if (null tree) 
      (list sym NIL NIL)
      (let ((n1 (nodes (second tree)))
            (n2 (nodes (third tree))))
        (cond ((= n1 n2)
               ;; add nodes to both branches
               (union (mapcar (lambda (tr) (list sym (second tree) tr))
                        (gen-cbal-trees (third tree)))
                      (mapcar (lambda (tr) (list sym tr (third tree)))
                        (gen-cbal-trees (second tree)))))
              ((< n1 n2)
               ;; only add to left
               (mapcar (lambda (tr) (list sym tr (third tree)))
                 (gen-cbal-trees (second tree))))
              (T
               ;; only add to right
               (mapcar (lambda (tr) (list sym (second tree) tr))
                 (gen-cbal-trees (third tree))))))))

(defun cbal-tree-p (tree)
  "Return T if TREE is completely balanced."
  (or (null tree)
      (and (tree-p tree)
           (<= (abs (- (nodes (second tree)) 
                       (nodes (third tree)))) 
               1)
           (cbal-tree-p (second tree))
           (cbal-tree-p (third tree)))))

(defun nodes (tree)
  "Return the number of nodes in TREE."
  (if (null tree)
      0
      (+ 1 (nodes (second tree)) (nodes (third tree)))))

;;; p56

(defun symmetric-p (tree)
  "Return T if the left branch of TREE is the mirror image of the right branch."
  (or (null tree)
      (mirror-p (second tree) (third tree))))

(defun mirror-p (tree1 tree2)
  "Return T if TREE1 is the mirror image of TREE2."
  (if (null tree1)
      (null tree2)
      (and (mirror-p (second tree1) (third tree2))
           (mirror-p (third tree1) (second tree2)))))

;;; p57

(defun make-bst (list)
  "Construct binary search tree from list of numbers."
  (do ((tree NIL (bst-insert (pop list) tree)))
      ((null list) tree)))

(defun bst-insert (item tree)
  "Insert item into binary search tree."
  (cond ((null tree) (list item NIL NIL))
        ((= item (first tree)) tree)
        ((< item (first tree))
         (list (first tree) 
               (bst-insert item (second tree)) 
               (third tree)))
        (T
         (list (first tree)
               (second tree)
               (bst-insert item (third tree))))))

(defun test-symmetric (list)
  "Test if the binary search tree constructed from LIST is symmetric."
  (symmetric-p (make-bst list)))
  
;;; p58

(defun sym-cbal-trees (n)
  "Generate all symmetric, completely balanced trees with the given number of nodes."
  (remove-if-not #'symmetric-p (cbal-trees n)))

(defun sym-cbal-tree-count (n)
  "Return the number of symmetric completely balanced trees with the given number of nodes."
  (length (sym-cbal-trees n)))

;;; p59

(defun hbal-tree-p (tree)
  "Return T if TREE is height balanced, i.e. for every node the difference of height between subtrees is not greater than 1."
  (or (null tree)
      (and (tree-p tree)
           (<= (abs (- (height (second tree)) 
                       (height (third tree)))) 
               1)
           (hbal-tree-p (second tree))
           (hbal-tree-p (third tree)))))

(defun hbal-trees (n)
  "Generate all height-balanced trees with the given number of nodes."
  (when (> n 0)
    (reduce #'union (mapcar #'gen-hbal-trees (hbal-trees (1- n))))))

(defun gen-hbal-trees (tree &aux (sym 'X))
  "Generate all height-balanced trees that can be generated by adding a node to a leaf of TREE."
  (labels ((gen-right (tree1)
             (mapcar (lambda (tr) (list sym (second tree1) tr))
               (gen-hbal-trees (third tree1))))
           (gen-left (tree1)
             (mapcar (lambda (tr) (list sym tr (third tree1)))
               (gen-hbal-trees (second tree1)))))
    (if (null tree)
        (list sym NIL NIL)
        (let ((h1 (height (second tree)))
              (h2 (height (third tree))))
          (cond ((<= (abs (- h1 h2)) 1)
                 (union (gen-left tree) (gen-right tree)))
                ((< h1 h2)
                 (gen-left tree))
                (T (gen-right tree)))))))

(defun height (tree)
  "Return the height of TREE."
  (if (null tree)
      0
      (1+ (max (height (second tree))
               (height (third tree))))))

;;; p60

(defun min-nodes (height)
  "Return the minimum number of nodes in a height-balanced tree with given height."
  (if (= height 0)
      0
      ;; assume one subtree is always shorter than the other
      (+ 1 (min-nodes (1- height))
           (min-nodes (- height 2)))))

(defun max-height (nodes)
  "Return the maximum height in a height-balanced tree with the given number of nodes."
  (if (= nodes 0)
      0
      ;; this is much better suited for Prolog backtracking
      (do ((n (ceiling (1- nodes) 2) (1+ n))
           (max 0))
          ((= n nodes) (1+ max))
          (let ((h1 (max-height n))
                (h2 (max-height (- nodes n))))
            (when (<= (abs (- h1 h2)) 1) ;once this is falsified, it shouldn't hold true again
              (setf max (max max h1 h2)))))))

(defun min-height (nodes)
  "Return the minimum height in a height-balanced tree with the given number of nodes."
  (if (= nodes 0)
      0
      ;; assume it is as balanced as possible
      (1+ (max (min-height (floor (1- nodes) 2))
               (min-height (ceiling (1- nodes) 2))))))

(defun hbal-tree-nodes (nodes)
  "Construct all height-balanced trees with the given number of nodes."
  (remove-if-not (lambda (tree)
                   (= (nodes tree) nodes))
    (reduce #'union (mapcar #'hbal-trees (range (min-height nodes) (max-height nodes))))))
