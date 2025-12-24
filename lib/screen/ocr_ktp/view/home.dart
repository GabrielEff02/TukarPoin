import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';

import 'package:e_commerce/constant/dialog_constant.dart';
import 'package:e_commerce/screen/gabriel/checkouts/show_items_screen/show_items_screen.dart';
import 'package:e_commerce/screen/gabriel/core/app_export.dart';
import 'package:e_commerce/screen/home/landing_home.dart';
import 'package:e_commerce/screen/ocr_ktp/controller/kecamatan_controller.dart';
import 'package:e_commerce/screen/ocr_ktp/controller/kelurahan_controller.dart';
import 'package:e_commerce/screen/ocr_ktp/controller/kota_controller.dart';
import 'package:e_commerce/screen/ocr_ktp/controller/province_controller.dart';
import 'package:e_commerce/screen/ocr_ktp/model/kecamatan_model.dart';
import 'package:e_commerce/screen/ocr_ktp/model/kota_model.dart';
import 'package:e_commerce/screen/ocr_ktp/model/ocr_result_model.dart';
import 'package:e_commerce/screen/ocr_ktp/model/provinsi_model.dart';
import 'package:e_commerce/screen/ocr_ktp/widget/textfield.dart';

class KtpOCR extends StatefulWidget {
  bool isCheckout = false;
  KtpOCR({
    Key? key,
    Map<String, dynamic>? postTransaction,
    List<dynamic>? postDetail,
    this.isCheckout = false,
  });

  @override
  State<KtpOCR> createState() => _KtpOCRState();
}

class _KtpOCRState extends State<KtpOCR> {
  late ProvinceController provinceController;
  late CityController cityController;
  late KecamatanController kecamatanControl;
  late KelurahanController kelurahanControl;
  final TextEditingController nikController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController rtController = TextEditingController();
  final TextEditingController rwController = TextEditingController();
  final golDarahController = "".obs;
  final jenisKelaminController = "".obs;
  final agamaController = "".obs;
  final kewarganegaraanController = "".obs;
  final TextEditingController pekerjaanController = TextEditingController();
  final TextEditingController tempatlahirController = TextEditingController();
  final TextEditingController tgllahirController = TextEditingController();
  final statusPerkawinanController = "".obs;
  final result = Rxn<OcrResultModel>();
  @override
  void initState() {
    super.initState();

    provinceController = Get.put(ProvinceController());
    cityController = Get.put(CityController());
    kecamatanControl = Get.put(KecamatanController());
    kelurahanControl = Get.put(KelurahanController());
    _initializeData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _initializeData() async {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        DialogConstant.loading(context, 'Loading...');
      });

      if (await LocalData.containsKey('detailKTP')) {
        ever(provinceController.provinces, (_) async {
          if (provinceController.provinces.isNotEmpty) {
            await fillData();
            Get.back();
          }
        });
      } else {
        Get.back();
      }
    }
  }

  Future<void> fillData() async {
    final data = jsonDecode(await LocalData.getData('detailKTP'));
    var selectedProvince;
    var selectedCity;
    var selectedKecamatan;
    List<String> parts = data['tanggal_lahir'].split("-");
    data['tanggal_lahir'] = "${parts[2]}-${parts[1]}-${parts[0]}";

    // province
    for (ProvinsiElement province in provinceController.provinces) {
      if (province.name.toUpperCase() == data['provinsi']) {
        selectedProvince = province;
      }
    }
    // city
    await cityController.fetchCities(selectedProvince.id);
    for (City city in cityController.cities) {
      if (city.name.toUpperCase() == data['kota']) {
        selectedCity = city;
      }
    }

    await kecamatanControl.fetchKecamatanModel(selectedCity.id);
    for (Kecamatan kecamatan in kecamatanControl.kecamatanModel.kecamatan) {
      if (kecamatan.nama.toUpperCase() == data['kecamatan']) {
        selectedKecamatan = kecamatan;
      }
    }
    await kelurahanControl.fetchKelurahanModel(selectedKecamatan.id);

    setState(() {
      nikController.text = data['nik'];
      nameController.text = data['nama'];
      tempatlahirController.text = data['tempat_lahir'];
      tgllahirController.text = data['tanggal_lahir'];
      jenisKelaminController.value = data['jenis_kelamin'];
      golDarahController.value = data['golongan_darah'];
      alamatController.text = data['alamat'];
      rtController.text = data['rt'];
      rwController.text = data['rw'];
      provinceController.selectedProvince.value = selectedProvince;
      cityController.selectedCity.value = selectedCity;
      kecamatanControl.selectedKecamatan = selectedKecamatan.id;
      kecamatanControl.selectedKecamatanName = selectedKecamatan.nama;
      kelurahanControl.selectedKelurahan = data['kelurahan'];
      agamaController.value = data['agama'];
      statusPerkawinanController.value = data['status_perkawinan'];
      pekerjaanController.text = data['pekerjaan'];
      kewarganegaraanController.value = data['kewarganegaraan'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'KTP',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
        child: Column(
          children: [
            widgetTextField(),
            const SizedBox(
              height: 12,
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFB3E5FC), // Light blue
                    Color.fromARGB(255, 61, 192, 253)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 4), // Shadow position
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors
                      .transparent, // Set to transparent to allow gradient
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded corners
                  ),
                  padding: EdgeInsets.symmetric(
                      vertical: 18, horizontal: 40), // Padding
                  elevation:
                      0, // Removing default shadow as we have custom shadow
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text("Are You Sure??"),
                      content: Text(
                          "Apakah anda sudah yakin data\nyang anda kirimkan sudah benar?"),
                      actions: <Widget>[
                        TextButton(
                          child: Text("OK"),
                          onPressed: () {
                            Navigator.of(context).pop();
                            if (!(nikController.text.isEmpty ||
                                nameController.text.isEmpty ||
                                tempatlahirController.text.isEmpty ||
                                tgllahirController.text.isEmpty ||
                                jenisKelaminController.value == null ||
                                golDarahController.value == null ||
                                alamatController.text.isEmpty ||
                                rtController.text.isEmpty ||
                                rwController.text.isEmpty ||
                                kelurahanControl.selectedKelurahan == null ||
                                kecamatanControl.selectedKecamatanName ==
                                    null ||
                                cityController.selectedCity.value == null ||
                                provinceController.selectedProvince.value ==
                                    null ||
                                agamaController.value == null ||
                                statusPerkawinanController.value == null ||
                                pekerjaanController.text.isEmpty ||
                                kewarganegaraanController.value == null)) {
                              _postData(
                                {
                                  'nik': nikController.text,
                                  'nama': nameController.text,
                                  'tempat_lahir': tempatlahirController.text,
                                  'tanggal_lahir': tgllahirController.text,
                                  'jenis_kelamin': jenisKelaminController.value,
                                  'golongan_darah': golDarahController.value,
                                  'alamat': alamatController.text,
                                  'rt': rtController.text,
                                  'rw': rwController.text,
                                  'kelurahan':
                                      kelurahanControl.selectedKelurahan,
                                  'kecamatan':
                                      kecamatanControl.selectedKecamatanName,
                                  'kota':
                                      cityController.selectedCity.value!.name,
                                  'provinsi': provinceController
                                      .selectedProvince.value!.name,
                                  'agama': agamaController.value,
                                  'status_perkawinan':
                                      statusPerkawinanController.value,
                                  'pekerjaan': pekerjaanController.text,
                                  'kewarganegaraan':
                                      kewarganegaraanController.value,
                                },
                              );
                            } else {
                              DialogConstant.alertError('Registrasi',
                                  'Data belum terisi dengan lengkap');
                            }
                          },
                        ),
                        TextButton(
                          child: Text("CANCEL"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  );
                },
                child: Text(
                  "Submit", // Button text
                  style: TextStyle(
                    fontSize: 18, // Font size
                    fontWeight: FontWeight.w600, // Font weight
                    letterSpacing: 1.5, // Spacing between letters
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DropdownMenuItem _menuList(value, text) {
    return DropdownMenuItem(
      value: value,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10.adaptSize),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _postData(listController) async {
    DialogConstant.loading(context, 'Loading...');
    listController['username'] = await LocalData.getData('user');
    API.basePost(
      "/api/poin/input-ktp",
      listController,
      {'Content-Type': 'application/json'},
      true,
      (result, error) {
        if (result != null && result['error'] != true) {
          setState(
            () {
              LocalData.saveData(
                'detailKTP',
                jsonEncode(listController),
              );
              LocalData.saveData('full_name', listController['nama']);
            },
          );

          widget.isCheckout
              ? Get.to(ShowItemsScreen())
              : Get.offAll(LandingHome());
          DialogConstant.showSuccessAlert(
              title: 'Success', message: 'Profil berhasil diperbarui!');
        } else {
          Navigator.pop(context);
          DialogConstant.alertError('Registrasi Gagal', result['message']);
        }
      },
    );
  }

  String truncateText(String text, {int maxLength = 20}) {
    return text.length > maxLength
        ? "${text.substring(0, maxLength)}..."
        : text;
  }

  Column widgetTextField() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => MyTextField(
                  inputType: 'number',
                  prefixIcon: true,
                  icon:
                      const Icon(Icons.badge_outlined, color: Colors.blueGrey),
                  initialData: result.value?.ktp?.nik,
                  controller: nikController,
                  title: "NIK",
                  maxLength: 16,
                ),
              ),
              const SizedBox(height: 10),
              Obx(
                () => MyTextField(
                    inputType: 'string',
                    prefixIcon: true,
                    icon: const Icon(Icons.person_outline, color: Colors.grey),
                    initialData: result.value?.ktp?.nama,
                    controller: nameController,
                    title: "Nama"),
              ),
              const SizedBox(height: 10),
              Obx(
                () => MyTextField(
                    inputType: 'string',
                    icon: const Icon(Icons.location_city_outlined,
                        color: Colors.orange),
                    initialData: result.value?.ktp?.tempatLahir,
                    controller: tempatlahirController,
                    title: "Tempat Lahir"),
              ),
              const SizedBox(height: 10),
              Obx(
                () => MyTextField(
                    inputType: 'date',
                    icon:
                        const Icon(Icons.event_outlined, color: Colors.purple),
                    initialData: result.value?.ktp?.tglLahir,
                    controller: tgllahirController,
                    title: "Tanggal Lahir"),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Text(
                  "Jenis Kelamin",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey[100]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField(
                    hint: const Text("Jenis Kelamin"),
                    value: jenisKelaminController.value.isEmpty
                        ? null
                        : jenisKelaminController.value,
                    items: [
                      {'text': "LAKI - LAKI", 'value': 'L'},
                      {'text': "PEREMPUAN", 'value': 'P'}
                    ]
                        .map(
                          (item) => _menuList(item['value'], item['text']),
                        )
                        .toList(),
                    onChanged: (newValue) {
                      jenisKelaminController.value = newValue;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                          jenisKelaminController.value.isEmpty
                              ? Icons.wc
                              : jenisKelaminController.value == "L"
                                  ? Icons.man
                                  : Icons.woman,
                          color: Colors.blueAccent),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Text(
                  "Golongan Darah",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey[100]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField(
                    hint: const Text("Golongan Darah"),
                    value: golDarahController.value.isEmpty
                        ? null
                        : golDarahController.value,
                    items: ['-', "A", "AB", "B", "O"]
                        .map(
                          (item) => _menuList(item, item),
                        )
                        .toList(),
                    onChanged: (newValue) {
                      golDarahController.value = newValue;
                    },
                    decoration: InputDecoration(
                      prefixIcon: golDarahController.value == "O"
                          ? const Icon(Icons.circle_outlined,
                              color: Colors.red) // O
                          : golDarahController.value == "A"
                              ? const Icon(Icons.looks_one_outlined,
                                  color: Colors.blue) // A
                              : golDarahController.value == "B"
                                  ? const Icon(Icons.looks_two_outlined,
                                      color: Colors.green) // B
                                  : golDarahController.value == "AB"
                                      ? const Icon(Icons.merge_type_outlined,
                                          color: Colors.purple) // AB
                                      : const Icon(Icons.bloodtype_outlined,
                                          color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Obx(
                () => MyTextField(
                    inputType: 'string',
                    icon: const Icon(Icons.location_on_outlined,
                        color: Colors.redAccent),
                    initialData: result.value?.ktp?.alamat,
                    controller: alamatController,
                    title: "Alamat"),
              ),
              const SizedBox(height: 10),
              Obx(
                () => MyTextField(
                  inputType: 'number',
                  icon:
                      const Icon(Icons.home_work_outlined, color: Colors.teal),
                  initialData: result.value?.ktp?.rt,
                  controller: rtController,
                  title: "RT",
                  maxLength: 3,
                ),
              ),
              const SizedBox(height: 10),
              Obx(
                () => MyTextField(
                  inputType: 'number',
                  icon:
                      const Icon(Icons.home_work_outlined, color: Colors.teal),
                  initialData: result.value?.ktp?.rw,
                  controller: rwController,
                  title: "RW",
                  maxLength: 3,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Text(
                  "Provinsi",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey[100]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField(
                    hint: const Text("Pilih Provinsi"),
                    value: provinceController.selectedProvince.value?.name,
                    items: provinceController.provinces
                        .map(
                          (province) => _menuList(province.name, province.name),
                        )
                        .toList(),
                    onChanged: (newValue) {
                      final selectedProvince = provinceController.provinces
                          .firstWhere((province) => province.name == newValue);
                      provinceController.selectedProvince.value =
                          selectedProvince;
                      cityController.fetchCities(selectedProvince.id);

                      cityController.selectedCity.value = null;
                      kecamatanControl.selectedKecamatan = null;
                      kelurahanControl.selectedKelurahan = null;
                    },
                    decoration: const InputDecoration(
                      prefixIcon:
                          Icon(Icons.pin_drop, color: Colors.blueAccent),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    ),
                    selectedItemBuilder: (BuildContext context) {
                      return provinceController.provinces.map((province) {
                        return Text(truncateText(province.name));
                      }).toList();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Text(
                  "Kabupaten / Kota",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
              Obx(
                () => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey[100]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField(
                    hint: const Text("Pilih Kabupaten / Kota"),
                    value: cityController.selectedCity.value,
                    items: cityController.cities.map(
                      (city) {
                        return _menuList(city, city.name);
                      },
                    ).toList(),
                    onChanged: (value) {
                      cityController.selectedCity.value = value;
                      kecamatanControl.fetchKecamatanModel(
                          cityController.selectedCity.value!.id);

                      kecamatanControl.selectedKecamatan = null;
                      kelurahanControl.selectedKelurahan = null;
                    },
                    decoration: const InputDecoration(
                      prefixIcon:
                          Icon(Icons.pin_drop, color: Colors.blueAccent),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    ),
                    selectedItemBuilder: (BuildContext context) {
                      return cityController.cities.map((city) {
                        return Text(truncateText(city.name));
                      }).toList();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Text(
                  "Kecamatan",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey[100]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField(
                    hint: const Text("Pilih Kecamatan"),
                    value: kecamatanControl.selectedKecamatan,
                    items: kecamatanControl.kecamatanModel.kecamatan
                        .map(
                          (kecamatan) =>
                              _menuList(kecamatan.id, kecamatan.nama),
                        )
                        .toList(),
                    onChanged: (value) {
                      kecamatanControl.selectedKecamatan = value;
                      kecamatanControl.selectedKecamatanName = kecamatanControl
                          .kecamatanModel.kecamatan
                          .firstWhere((kecamatan) => kecamatan.id == value)
                          .nama;
                      kelurahanControl.fetchKelurahanModel(
                          kecamatanControl.selectedKecamatan!);
                      kelurahanControl.selectedKelurahan = null;
                    },
                    decoration: const InputDecoration(
                      prefixIcon:
                          Icon(Icons.pin_drop, color: Colors.blueAccent),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    ),
                    selectedItemBuilder: (BuildContext context) {
                      return kecamatanControl.kecamatanModel.kecamatan
                          .map((kecamatan) {
                        return Text(truncateText(kecamatan.nama));
                      }).toList();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Text(
                  "Kelurahan",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey[100]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField(
                    value: kelurahanControl.selectedKelurahan,
                    hint: const Text("Pilih Kel/Desa"),
                    items: kelurahanControl.kelurahanModel.kelurahan
                        .map(
                          (kelurahan) =>
                              _menuList(kelurahan.nama, kelurahan.nama),
                        )
                        .toList(),
                    onChanged: (value) {
                      kelurahanControl.selectedKelurahan = value;
                    },
                    decoration: const InputDecoration(
                      prefixIcon:
                          Icon(Icons.pin_drop, color: Colors.blueAccent),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    ),
                    selectedItemBuilder: (BuildContext context) {
                      return kelurahanControl.kelurahanModel.kelurahan
                          .map((kelurahan) {
                        return Text(truncateText(kelurahan.nama));
                      }).toList();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Text(
                  "Agama",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey[100]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField(
                    hint: const Text("Agama"),
                    value: agamaController.value.isEmpty
                        ? null
                        : agamaController.value,
                    items: [
                      "BUDDHA",
                      "HINDU",
                      "ISLAM",
                      "KONGHUCU",
                      "KATHOLIK",
                      "KRISTEN",
                    ]
                        .map(
                          (item) => _menuList(item, item),
                        )
                        .toList(),
                    onChanged: (newValue) {
                      agamaController.value = newValue;
                    },
                    decoration: InputDecoration(
                      prefixIcon: agamaController.value == "ISLAM"
                          ? const Icon(Icons.mosque, color: Colors.green)
                          : agamaController.value == "KRISTEN" ||
                                  agamaController.value == "KATHOLIK"
                              ? const Icon(Icons.church, color: Colors.blue)
                              : agamaController.value == "HINDU"
                                  ? const Icon(Icons.temple_hindu,
                                      color: Colors.orange)
                                  : agamaController.value == "BUDDHA"
                                      ? const Icon(Icons.temple_buddhist,
                                          color: Colors.yellow)
                                      : agamaController.value == "KONGHUCU"
                                          ? const Icon(Icons.balance,
                                              color: Colors.grey)
                                          : const Icon(Icons.account_balance,
                                              color: Colors.black54),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Text(
                  "Status Perkawinan",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey[100]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField(
                    hint: const Text("Status Perkawinan"),
                    value: statusPerkawinanController.value.isEmpty
                        ? null
                        : statusPerkawinanController.value,
                    items: ["BELUM KAWIN", "KAWIN", "CERAI HIDUP", "CERAI MATI"]
                        .map(
                          (item) => _menuList(item, item),
                        )
                        .toList(),
                    onChanged: (newValue) {
                      statusPerkawinanController.value = newValue;
                    },
                    decoration: InputDecoration(
                      prefixIcon: statusPerkawinanController.value ==
                              "BELUM KAWIN"
                          ? const Icon(Icons.person_outline,
                              color: Colors.blueGrey)
                          : statusPerkawinanController.value == "KAWIN"
                              ? const Icon(Icons.favorite, color: Colors.red)
                              : statusPerkawinanController.value ==
                                      "CERAI HIDUP"
                                  ? const Icon(Icons.link_off,
                                      color: Colors.orange)
                                  : statusPerkawinanController.value ==
                                          "CERAI MATI"
                                      ? const Icon(Icons.heart_broken,
                                          color: Colors.purple)
                                      : const Icon(Icons.people_outline,
                                          color: Colors.black54),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Obx(
                () => MyTextField(
                    inputType: 'string',
                    icon: const Icon(Icons.work, color: Colors.black),
                    initialData: result.value?.ktp?.pekerjaan,
                    controller: pekerjaanController,
                    title: "Pekerjaan"),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Text(
                  "Kewarganegaraan",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey[100]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField(
                    hint: const Text("Kewarganegaraam"),
                    value: kewarganegaraanController.value.isEmpty
                        ? null
                        : kewarganegaraanController.value,
                    items: ["WNA", "WNI"]
                        .map(
                          (item) => _menuList(item, item),
                        )
                        .toList(),
                    onChanged: (newValue) {
                      kewarganegaraanController.value = newValue;
                    },
                    decoration: InputDecoration(
                      prefixIcon: kewarganegaraanController.value == "WNI"
                          ? const Icon(Icons.flag, color: Colors.red)
                          : kewarganegaraanController.value == "WNA"
                              ? const Icon(Icons.public, color: Colors.blue)
                              : const Icon(Icons.help_outline,
                                  color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }
}
