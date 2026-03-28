import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({Key? key}) : super(key: key);

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  String _selectedCategory = 'Infrastructure';
  double _priorityLevel = 1; // 0: Low, 1: Medium, 2: Critical
  bool _isAnonymous = false;
  bool _isLocationFound = false;
  bool _isSubmitting = false;
  Position? _currentPosition;
  bool _isInitialized = false;
  String? _editDocId; // non-null when editing an existing report

  XFile? _imageFile;
  String? _audioPath;
  String _description = '';
  String _title = '';

  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedSector;

  final List<String> _provinces = [
    'Kigali City',
    'Eastern Province',
    'Western Province',
    'Northern Province',
    'Southern Province',
  ];

  final Map<String, List<String>> _provinceToDistricts = {
    'Kigali City': ['Gasabo', 'Kicukiro', 'Nyarugenge'],
    'Eastern Province': [
      'Bugesera',
      'Gatsibo',
      'Kayonza',
      'Kirehe',
      'Ngoma',
      'Nyagatare',
      'Rwamagana',
    ],
    'Western Province': [
      'Karongi',
      'Ngororero',
      'Nyabihu',
      'Nyamasheke',
      'Rubavu',
      'Rusizi',
      'Rutsiro',
    ],
    'Northern Province': ['Burera', 'Gakenke', 'Gicumbi', 'Musanze', 'Rulindo'],
    'Southern Province': [
      'Gisagara',
      'Huye',
      'Kamonyi',
      'Muhanga',
      'Nyamagabe',
      'Nyanza',
      'Nyaruguru',
      'Ruhango',
    ],
  };

  final Map<String, List<String>> _districtsAndSectors = {
    'Gasabo': [
      'Bumbogo',
      'Gatsata',
      'Gisozi',
      'Kacyiru',
      'Kimihurura',
      'Kimironko',
      'Kinyinya',
      'Ndera',
      'Nduba',
      'Remera',
      'Rusororo',
      'Rutunga',
    ],
    'Nyarugenge': [
      'Gitega',
      'Kanyinya',
      'Kigali',
      'Kimisagara',
      'Mageragere',
      'Muhima',
      'Nyakabanda',
      'Nyamirambo',
      'Nyarugenge',
      'Rwezamenyo',
    ],
    'Kicukiro': [
      'Gahanga',
      'Gatenga',
      'Gikondo',
      'Kagarama',
      'Kanombe',
      'Kicukiro',
      'Kigarama',
      'Masaka',
      'Niboye',
      'Nyarugunga',
    ],
    'Rusizi': [
      'Bugarama',
      'Butare',
      'Bweyeye',
      'Gashonga',
      'Giheke',
      'Gihundwe',
      'Gitambi',
      'Kamembe',
      'Muganza',
      'Mururu',
      'Nkanka',
      'Nkombo',
      'Nkungu',
      'Nyakabuye',
      'Nyakarenzo',
      'Nzahaha',
      'Rwimbogo',
    ],
    'Rubavu': [
      'Bugeshi',
      'Busasamana',
      'Cyanzarwe',
      'Gisenyi',
      'Kanama',
      'Kanzenze',
      'Mudende',
      'Nyamyumba',
      'Nyundo',
      'Rubavu',
      'Rugerero',
      'Rukoko',
    ],
    'Musanze': [
      'Busogo',
      'Cyuve',
      'Gacaca',
      'Gashaki',
      'Gataraga',
      'Kimonyi',
      'Kinigi',
      'Muhoza',
      'Muko',
      'Nkotsi',
      'Nyange',
      'Remera',
      'Rwaza',
      'Shingiro',
    ],
    'Kirehe': [
      'Gahara',
      'Gatore',
      'Kigarama',
      'Kirehe',
      'Mahama',
      'Mpanga',
      'Musaza',
      'Mushikiri',
      'Nasho',
      'Nyamugari',
      'Nyarubuye',
    ],
    'Bugesera': ['Gashora', 'Juru', 'Kamabuye', 'Ntarama', 'Nyamata', 'Rilima'],
    'Kayonza': [
      'Gahini',
      'Kabare',
      'Kabarondo',
      'Mukarange',
      'Murama',
      'Murundi',
      'Ndego',
      'Nyamirama',
      'Rukara',
      'Ruramira',
      'Rwinkwavu',
    ],
    'Gatsibo': [
      'Gasange',
      'Gatsibo',
      'Gitoki',
      'Kageyo',
      'Kiramuruzi',
      'Kiziguro',
      'Muhura',
      'Murambi',
      'Ngarama',
      'Nyagihanga',
      'Remera',
      'Rugarama',
      'Rwimbogo',
    ],
    'Nyagatare': [
      'Gatunda',
      'Kiyombe',
      'Karama',
      'Karangazi',
      'Katabagemu',
      'Matimba',
      'Mimuri',
      'Mukama',
      'Musheli',
      'Nyagatare',
      'Rukomo',
      'Rwempasha',
      'Tabagwe',
    ],
    'Ngoma': [
      'Gashanda',
      'Jarama',
      'Karembo',
      'Kazo',
      'Kibungo',
      'Mugesera',
      'Murama',
      'Mutenderi',
      'Remera',
      'Rukira',
      'Rukumberi',
      'Zaza',
    ],
    'Rwamagana': [
      'Fumbwe',
      'Gahengeri',
      'Gishari',
      'Karenge',
      'Kigabiro',
      'Muhazi',
      'Munyaga',
      'Munyiginya',
      'Musha',
      'Muyumbu',
      'Mwulire',
      'Nyakariro',
      'Nzige',
      'Rubona',
    ],
  };

  final TextEditingController _manualLocationController =
      TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (!_isInitialized && args != null) {
      _editDocId = args['docId'] as String?;
      _imageFile = args['imageFile'] as XFile?;
      _audioPath = args['audioPath'] as String?;
      _title = args['title'] as String? ?? '';
      _description = args['description'] as String? ?? '';
      // Pre-fill selectors when editing
      if (args['category'] != null)
        _selectedCategory = args['category'] as String;
      if (args['province'] != null)
        _selectedProvince = args['province'] as String;
      if (args['district'] != null)
        _selectedDistrict = args['district'] as String;
      if (args['sector'] != null) _selectedSector = args['sector'] as String;
      if (args['priority'] != null)
        _priorityLevel = (args['priority'] as num).toDouble();
      if (args['is_anonymous'] != null)
        _isAnonymous = args['is_anonymous'] as bool;
      if (args['manual_location'] != null) {
        _manualLocationController.text = args['manual_location'] as String;
      }
      _isInitialized = true;
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied.')),
          );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied.'),
          ),
        );
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _isLocationFound = true;
      });
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location acquired successfully!'),
            backgroundColor: Colors.green,
          ),
        );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: $e'),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  @override
  void dispose() {
    _manualLocationController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLocationSection(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Category',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'REQUIRED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildCategoryGrid(),
              const SizedBox(height: 24),
              _buildLocationSelectors(),
              const SizedBox(height: 32),
              Text(
                'Priority Level',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              _buildPrioritySlider(),
              const SizedBox(height: 16),
              _buildPriorityInfoBox(),
              const SizedBox(height: 32),
              _buildAnonymousToggle(),
              const SizedBox(height: 48), // Padding before final button
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildSubmitButton(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: scheme.primary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Create Report',
        style: TextStyle(
          color: scheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'STEP 2 OF 2',
                    style: TextStyle(
                      color: scheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'Incident Details',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _stepBar(
                    true,
                    onTap: () => Navigator.pop(context),
                  ), // back to step 1
                  const SizedBox(width: 4),
                  _stepBar(true, onTap: null), // current step
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepBar(bool filled, {VoidCallback? onTap}) {
    final scheme = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 5,
          decoration: BoxDecoration(
            color: filled ? scheme.primary : scheme.outline,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Incident Location',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _getCurrentLocation,
              icon: Icon(
                _isLocationFound ? Icons.check_circle : Icons.my_location,
                color: _isLocationFound
                  ? scheme.tertiary
                  : scheme.onPrimary,
              ),
              label: Text(
                _isLocationFound
                    ? 'Location Acquired'
                    : 'Get My Current Location',
                style: TextStyle(
                  color: _isLocationFound
                      ? scheme.tertiary
                      : scheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isLocationFound
                    ? scheme.tertiary.withValues(alpha: 0.2)
                    : scheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: _isLocationFound ? 0 : 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: _isLocationFound
                      ? BorderSide(color: scheme.tertiary)
                      : BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Use this if you are currently at the place where the incident or issue is located.',
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'OR',
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: scheme.outline.withValues(alpha: 0.5)),
            ),
            child: TextField(
              controller: _manualLocationController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'Enter street address or describe the exact location (e.g. near the high school, 500m after the first turn)...',
                hintStyle: TextStyle(
                  color: scheme.onSurfaceVariant,
                  height: 1.4,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: Icon(
                    Icons.location_on_outlined,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final scheme = Theme.of(context).colorScheme;
    final categories = [
      {'title': 'Infrastructure', 'icon': Icons.build},
      {'title': 'Health', 'icon': Icons.medical_services},
      {'title': 'Security', 'icon': Icons.security},
      {'title': 'Land', 'icon': Icons.landscape},
      {'title': 'Education', 'icon': Icons.school},
      {'title': 'Justice', 'icon': Icons.gavel},
      {'title': 'Social Welfare', 'icon': Icons.people},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: categories.map((cat) {
        final isSelected = _selectedCategory == cat['title'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = cat['title'] as String;
            });
          },
          child: Container(
            width: (MediaQuery.of(context).size.width - 52) / 2, // 2 columns
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? scheme.primary
                    : scheme.outline,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? scheme.primary
                        : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    cat['icon'] as IconData,
                    color: isSelected ? scheme.onPrimary : scheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  cat['title'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? scheme.primary
                        : scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLocationSelectors() {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_city, color: scheme.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Incident Location Details',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Province Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: scheme.outline.withValues(alpha: 0.6)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedProvince,
                hint: const Text('Select Province'),
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down, color: scheme.onSurface),
                items: _provinces.map((String province) {
                  return DropdownMenuItem<String>(
                    value: province,
                    child: Text(province),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedProvince = newValue;
                    _selectedDistrict = null; // Reset district
                    _selectedSector = null; // Reset sector
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // District Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _selectedProvince == null
                  ? scheme.surfaceContainerHighest
                  : scheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: scheme.outline.withValues(alpha: 0.6)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedDistrict,
                hint: const Text('Select Target District'),
                isExpanded: true,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: _selectedProvince == null
                      ? scheme.outline
                      : scheme.onSurface,
                ),
                items: _selectedProvince == null
                    ? []
                    : (_provinceToDistricts[_selectedProvince] ?? []).map((
                        String district,
                      ) {
                        return DropdownMenuItem<String>(
                          value: district,
                          child: Text(district),
                        );
                      }).toList(),
                onChanged: _selectedProvince == null
                    ? null
                    : (newValue) {
                        setState(() {
                          _selectedDistrict = newValue;
                          _selectedSector = null; // Reset sector
                        });
                      },
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Sector Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _selectedDistrict == null
                  ? scheme.surfaceContainerHighest
                  : scheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: scheme.outline.withValues(alpha: 0.6)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSector,
                hint: const Text('Select Sector'),
                isExpanded: true,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: _selectedDistrict == null
                      ? scheme.outline
                      : scheme.onSurface,
                ),
                items: _selectedDistrict == null
                    ? []
                    : (_districtsAndSectors[_selectedDistrict] ??
                              ['Main Sector'])
                          .map((String sector) {
                            return DropdownMenuItem<String>(
                              value: sector,
                              child: Text(sector),
                            );
                          })
                          .toList(),
                onChanged: _selectedDistrict == null
                    ? null
                    : (newValue) {
                        setState(() {
                          _selectedSector = newValue;
                        });
                      },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrioritySlider() {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: scheme.primary,
            inactiveTrackColor: scheme.outline,
            thumbColor: scheme.onPrimary,
            overlayColor: scheme.primary.withValues(alpha: 0.2),
            trackHeight: 4.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 24.0),
          ),
          child: Slider(
            value: _priorityLevel,
            min: 0,
            max: 2,
            divisions: 2,
            onChanged: (double value) {
              setState(() {
                _priorityLevel = value;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPriorityLabel(
                'LOW',
                scheme.tertiary,
                _priorityLevel == 0,
              ),
              _buildPriorityLabel(
                'MEDIUM',
                scheme.secondary,
                _priorityLevel == 1,
              ),
              _buildPriorityLabel(
                'CRITICAL',
                scheme.error,
                _priorityLevel == 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityLabel(String text, Color color, bool isSelected) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityInfoBox() {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.25)),
      ),
      child: Text(
        '"Medium urgency reports are typically reviewed within 24-48 business hours."',
        style: TextStyle(
          color: scheme.primary,
          fontSize: 13,
          fontStyle: FontStyle.italic,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildAnonymousToggle() {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Anonymously',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Hide my identity from the public community feed.',
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
        Switch(
          value: _isAnonymous,
          onChanged: (value) {
            setState(() {
              _isAnonymous = value;
            });
          },
          activeColor: scheme.onPrimary,
          activeTrackColor: scheme.tertiary,
          inactiveThumbColor: scheme.onPrimary,
          inactiveTrackColor: scheme.outline,
        ),
      ],
    );
  }

  static const String _cloudinaryCloudName = 'doigncrt4';
  static const String _cloudinaryUploadPreset = 'civic-fix';

  Future<String?> _uploadToCloudinary(
    List<int> bytes,
    String resourceType,
    String publicId,
  ) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudinaryCloudName/$resourceType/upload',
      );

      final cleanFilename =
          '${publicId}.${resourceType == 'image' ? 'jpg' : 'mp4'}';
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _cloudinaryUploadPreset
        ..fields['public_id'] = publicId
        ..fields['filename_override'] = cleanFilename
        ..files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: cleanFilename),
        );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return data['secure_url'] as String?;
      } else {
        debugPrint('Cloudinary error: $responseBody');
        return null;
      }
    } catch (e) {
      debugPrint('Cloudinary upload error: $e');
      return null;
    }
  }

  Future<void> _submitReport() async {
    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null)
        throw Exception('User not logged in. Please sign in again.');

      if (_selectedDistrict == null || _selectedSector == null) {
        throw Exception('Please select a Target District and Sector.');
      }

      String? imageUrl;
      String? audioUrl;
      final ticketId = _editDocId ?? const Uuid().v4();

      // Clear '#' and other special chars from ticketId for Cloudinary happy IDs
      final safeTicketId = ticketId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Upload new Image to Cloudinary (if a new one was selected)
      if (_imageFile != null) {
        final bytes = await _imageFile!.readAsBytes();
        imageUrl = await _uploadToCloudinary(
          bytes,
          'image',
          'issues_${safeTicketId}_photo_$timestamp',
        );
      }

      // Upload new Audio to Cloudinary (if a new one was recorded)
      if (_audioPath != null) {
        final audioBytes = kIsWeb
            ? (await http.get(Uri.parse(_audioPath!))).bodyBytes
            : await File(_audioPath!).readAsBytes();
        audioUrl = await _uploadToCloudinary(
          audioBytes,
          'video',
          'issues_${safeTicketId}_audio_$timestamp',
        );
      }

      final Map<String, dynamic> updateData = {
        'title': _title.isNotEmpty ? _title : _description,
        'category': _selectedCategory,
        'province': _selectedProvince,
        'district': _selectedDistrict,
        'sector': _selectedSector,
        'priority': _priorityLevel,
        'description': _description,
        'is_anonymous': _isAnonymous,
        'manual_location': _manualLocationController.text.trim(),
        'latitude': _currentPosition?.latitude,
        'longitude': _currentPosition?.longitude,
      };
      // Only update media URLs if new ones were uploaded
      if (imageUrl != null) updateData['photo_url'] = imageUrl;
      if (audioUrl != null) updateData['audio_url'] = audioUrl;

      if (_editDocId != null) {
        // ── EDIT MODE: update existing document ──
        await FirebaseFirestore.instance
            .collection('issues')
            .doc(_editDocId)
            .update(updateData);
      } else {
        // ── CREATE MODE: new document ──
        final user = FirebaseAuth.instance.currentUser!;
        await FirebaseFirestore.instance
            .collection('issues')
            .doc(ticketId)
            .set({
              ...updateData,
              'ticket_id': ticketId,
              'reported_by_uid': user.uid,
              'status': 'Submitted',
              'timestamp': FieldValue.serverTimestamp(),
              'upvotes': [],
            });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _editDocId != null
                  ? 'Report updated!'
                  : 'Incident reported successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/my-reports',
          (route) => route.isFirst,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildSubmitButton() {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submitReport,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            backgroundColor: scheme.primary,
            elevation: 4,
            shadowColor: scheme.primary.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Submit to District',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                  ],
                ),
        ),
      ),
    );
  }
}
