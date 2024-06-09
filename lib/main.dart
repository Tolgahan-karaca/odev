import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const MyHomePage(
        title: 'Barkod Okuyucu',
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _scanBarcodeResult = '';
  String _productName = '';
  double _productPrice = 0.0;
  List<Map<String, dynamic>> _scannedProducts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Builder(
        builder: (_) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  _startBarcodeScan(ScanMode.BARCODE);
                },
                child: Text("Barkod Taramasını Başlat"),
              ),
              Text("Barkod: $_scanBarcodeResult"),
              TextField(
                onChanged: (value) {
                  _productName = value;
                },
                decoration: InputDecoration(
                  hintText: 'Ürün Adı Girin',
                ),
              ),
              TextField(
                onChanged: (value) {
                  _productPrice = double.tryParse(value) ?? 0.0;
                },
                decoration: InputDecoration(
                  hintText: 'Ürün Fiyatı Girin',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_scanBarcodeResult.isNotEmpty &&
                      _productName.isNotEmpty &&
                      _productPrice > 0) {
                    setState(() {
                      _scannedProducts.add({
                        'barcode': _scanBarcodeResult,
                        'name': _productName,
                        'price': _productPrice,
                      });
                      _scanBarcodeResult = '';
                      _productName = '';
                      _productPrice = 0.0;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Lütfen önce bir barkod, ürün adı ve fiyat girin.'),
                      ),
                    );
                  }
                },
                child: Text("Ürünü Listeye Ekle"),
              ),
              ElevatedButton(
                onPressed: () {
                  _showScannedProductsDialog(context);
                },
                child: Text("Kayıtlı Ürünleri Görüntüle"),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _scannedProducts.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(
                          "Barkod: ${_scannedProducts[index]['barcode']}, Ürün Adı: ${_scannedProducts[index]['name']}, Fiyat: ${_scannedProducts[index]['price']}"),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _editProduct(index);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startBarcodeScan(ScanMode scanMode) async {
    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666",
        "cancel",
        true,
        scanMode,
      );
      setState(() {
        _scanBarcodeResult = barcodeScanRes;
      });
    } on PlatformException {
      setState(() {
        _scanBarcodeResult = "Failed to get platform version";
      });
    }
  }

  void _showScannedProductsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Kayıtlı Ürünler"),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _scannedProducts.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(
                      "Barkod: ${_scannedProducts[index]['barcode']}, Ürün Adı: ${_scannedProducts[index]['name']}, Fiyat: ${_scannedProducts[index]['price']}"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteProduct(index);
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Kapat"),
            ),
          ],
        );
      },
    );
  }

  void _editProduct(int index) {
    setState(() {
      _scanBarcodeResult = _scannedProducts[index]['barcode'];
      _productName = _scannedProducts[index]['name'];
      _productPrice = _scannedProducts[index]['price'];
      _scannedProducts.removeAt(index);
    });
  }

  void _deleteProduct(int index) {
    setState(() {
      _scannedProducts.removeAt(index);
    });
  }
}