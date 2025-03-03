import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

import 'trash_bin.dart';

class AnimatedAddButton extends StatefulWidget {
  final ValueChanged<String?> onCategorySelected;
  final String type;

  const AnimatedAddButton({
    super.key,
    required this.onCategorySelected,
    required this.type,
  });

  @override
  State<AnimatedAddButton> createState() => _AnimatedAddButtonState();
}

class _AnimatedAddButtonState extends State<AnimatedAddButton> {
  bool _isExpanded = false;
  final TextEditingController _textController = TextEditingController();
  final List<String> _categories = [];
  String? _selectedCategory;
  bool _showTrash = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      setState(() {});
    });
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('${widget.type}_categories')
          .get();
      setState(() {
        _categories.addAll(snapshot.docs.map((doc) => doc['name'] as String));
      });
    } catch (e) {
      print('Lỗi khi tải danh mục: $e');
    }
  }

  Future<void> _addCategory(String name) async {
    try {
      await FirebaseFirestore.instance
          .collection('${widget.type}_categories')
          .add({
        'name': name,
        'type': widget.type,
      });
      setState(() {
        _categories.add(name);
      });
    } catch (e) {
      print('Lỗi khi thêm danh mục: $e');
    }
  }

  Future<void> _deleteCategory(String categoryName, String type) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('${type}_categories')
          .where('name', isEqualTo: categoryName)
          .get();

      for(final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      print('Danh mục đã được xóa: $categoryName');
    } catch (e) {
      print('Lỗi khi xóa danh mục: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _isExpanded ? MediaQuery.of(context).size.width * 0.9 : 55,
              height: 55,
              child: _isExpanded
                  ? Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                child: Row(
                  children: [
                    Flexible(
                      child: TextField(
                        controller: _textController,
                        maxLength: 12,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: 'Nhập tên giao dịch...',
                          hintStyle: TextStyle(
                            color: Colors.grey.withOpacity(0.7),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.teal.withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                                color: Colors.teal, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 16,
                          ),
                          suffixIcon: _textController.text.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.check,
                                color: Colors.teal),
                            onPressed: () async {
                              if (_textController.text.isNotEmpty) {
                                await _addCategory(
                                    _textController.text);
                                setState(() {
                                  _isExpanded = false;
                                  _textController.clear();
                                });
                              }
                            },
                          )
                              : null,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _isExpanded = false;
                          _textController.clear();
                        });
                      },
                    ),
                  ],
                ),
              )
                  : DottedBorder(
                borderType: BorderType.RRect,
                radius: const Radius.circular(16),
                dashPattern: [6, 6],
                color: Colors.grey,
                strokeWidth: 1,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isExpanded = true;
                    });
                  },
                  child: Container(
                    height: 53,
                    width: 53,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.add, size: 22, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 170,
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories
                      .map((category) => _buildCategoryChip(category))
                      .toList(),
                ),
              ),
            )
          ],
        ),
        if (_showTrash)
          TrashBin(
            onAccept: (data) async {

              await _deleteCategory(data, widget.type);
              
              setState(() {
                _categories.remove(data);
                _showTrash = false;
              });
            }, type: widget.type,
          ),
      ],
    );
  }

  Widget _buildCategoryChip(String text) {
    bool isSelected = _selectedCategory == text;
    return LongPressDraggable<String>(
      data: text,
      onDragStarted: () {
        setState(() {
          _showTrash = true;
        });
      },
      onDragEnd: (details) {
        setState(() {
          _showTrash = false;
        });
      },
      feedback: Material(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
          decoration: BoxDecoration(
            color: isSelected ? Colors.teal : Colors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? Colors.white : Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.category,
                color: isSelected ? Colors.white : Colors.teal,
                size: 18,
              ),
            ],
          ),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = isSelected ? null : text;
            widget.onCategorySelected(_selectedCategory);
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
          decoration: BoxDecoration(
            color: isSelected ? Colors.teal : Colors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? Colors.white : Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.category,
                color: isSelected ? Colors.white : Colors.teal,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}