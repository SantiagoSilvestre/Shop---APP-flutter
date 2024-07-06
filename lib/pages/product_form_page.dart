import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/product.dart';
import 'package:shop/models/product_list.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _priceFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _formData = <String, Object>{};
  bool _isLoading = false;

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    // Adiciona o ouvinte ao FocusNode
    _imageUrlFocusNode.addListener(_updateImageUrl);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_formData.isEmpty) {
      final arg = ModalRoute.of(context)?.settings.arguments;

      if (arg != null) {
        final product = arg as Product;
        _formData['id'] = product.id;
        _formData['name'] = product.name;
        _formData['price'] = product.price;
        _formData['description'] = product.description;
        _formData['imageUrl'] = product.imageUrl;

        _imageUrlController.text = product.imageUrl;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _priceFocus.dispose();
    _descriptionFocus.dispose();

    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();
  }

  bool isValidImageUrl(String url) {
    final urlPattern =
        RegExp(r'http(s)?://.*\.(?:png|jpg|jpeg)'); // 'http://www.google.com'
    return urlPattern.hasMatch(url);
  }

  Future<void> _submitForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    _formKey.currentState?.save();

    setState(() => _isLoading = true);

    try {
      await Provider.of<ProductList>(
        context,
        listen: false,
      ).saveProduct(_formData);
      Navigator.of(context).pop();
    } catch (error) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ocorreu um erro'),
          content: const Text('Ocorreu um erro ao tentar salvar o produto'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            )
          ],
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products Forms'),
        actions: [
          IconButton(
            onPressed: _submitForm,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _formData['name']?.toString(),
                      decoration: const InputDecoration(labelText: 'Nome'),
                      onSaved: (name) => _formData['name'] = name ?? '',
                      validator: (nameField) {
                        final name = nameField ?? '';
                        if (name.trim().isEmpty) {
                          return 'Name is required.';
                        }

                        if (name.trim().length < 3) {
                          return 'Name must have at least 3 characters.';
                        }

                        return null;
                      },
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocus);
                      },
                    ),
                    TextFormField(
                      initialValue: _formData['price']?.toString(),
                      decoration: const InputDecoration(labelText: 'Preço'),
                      textInputAction: TextInputAction.next,
                      onSaved: (price) =>
                          _formData['price'] = double.parse(price ?? '0'),
                      validator: (priceField) {
                        final priceString = priceField ?? '';
                        final price = double.tryParse(priceString) ?? -1;
                        if (price <= 0) {
                          return 'Price must be greater than zero.';
                        }
                        return null;
                      },
                      focusNode: _priceFocus,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_descriptionFocus);
                      },
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                    TextFormField(
                      initialValue: _formData['description']?.toString(),
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      focusNode: _descriptionFocus,
                      onSaved: (description) =>
                          _formData['description'] = description ?? '',
                      validator: (descriptionField) {
                        final description = descriptionField ?? '';
                        if (description.trim().isEmpty) {
                          return 'Description is required.';
                        }

                        if (description.trim().length < 10) {
                          return 'Description must have at least 10 characters.';
                        }

                        return null;
                      },
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Image URL'),
                            focusNode: _imageUrlFocusNode,
                            controller: _imageUrlController,
                            onSaved: (imageUrl) =>
                                _formData['imageUrl'] = imageUrl ?? '',
                            validator: (imageUrlValidation) {
                              final imageUrl = imageUrlValidation ?? '';
                              if (!isValidImageUrl(imageUrl)) {
                                return 'Informe uma URL válida';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) => _submitForm(),
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.url,
                          ),
                        ),
                        Container(
                          height: 100,
                          width: 100,
                          margin: const EdgeInsets.only(
                            top: 10,
                            left: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: _imageUrlController.text.isEmpty
                              ? const Text('Informe a URL')
                              : Image.network(_imageUrlController.text),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
