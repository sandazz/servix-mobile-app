/// Service categories available in Servix
enum ServiceCategory {
  plumbing('Plumber', 'Plumbing'),
  electrical('ELECTRICAL', 'Electrical'),
  carpentry('CARPENTRY', 'Carpentry'),
  painting('PAINTING', 'Painting'),
  landscaping('LANDSCAPING', 'Landscaping'),
  gardening('GARDENING', 'Gardening'),
  hvac('HVAC', 'HVAC'),
  roofing('ROOFING', 'Roofing'),
  cleaning('CLEANING', 'Cleaning'),
  moving('MOVING', 'Moving'),
  security('SECURITY', 'Security'),
  other('OTHER', 'Other');

  final String key;
  final String displayName;

  const ServiceCategory(this.key, this.displayName);

  static ServiceCategory? fromKey(String key) {
    try {
      return ServiceCategory.values.firstWhere((e) => e.key == key);
    } catch (_) {
      return null;
    }
  }
}

/// Document types for service providers
enum DocumentType {
  policeCheck('POLICE_CHECK', 'Police Check', true),
  wwcc('WWCC', 'Working With Children Check', true),
  insurance('INSURANCE', 'Public Liability Insurance', true),
  tradeCertification('TRADE_CERTIFICATION', 'Trade Certification', false),
  education('EDUCATION', 'Education', false),
  experience('EXPERIENCE', 'Experience', false),
  photo('PHOTO', 'Profile Photo', true);

  final String key;
  final String displayName;
  final bool isMandatory;

  const DocumentType(this.key, this.displayName, this.isMandatory);

  static DocumentType? fromKey(String key) {
    try {
      return DocumentType.values.firstWhere((e) => e.key == key);
    } catch (_) {
      return null;
    }
  }
}

/// User types
enum UserType {
  serviceProvider('service-provider', 'Service Provider'),
  contractor('contractor', 'Client');

  final String key;
  final String displayName;

  const UserType(this.key, this.displayName);

  static UserType? fromKey(String key) {
    try {
      return UserType.values.firstWhere((e) => e.key == key);
    } catch (_) {
      return null;
    }
  }
}

/// Client account types
enum ClientType {
  personal('PERSONAL', 'Personal'),
  business('BUSINESS', 'Business');

  final String key;
  final String displayName;

  const ClientType(this.key, this.displayName);

  static ClientType? fromKey(String key) {
    try {
      return ClientType.values.firstWhere((e) => e.key == key);
    } catch (_) {
      return null;
    }
  }
}

/// Account status
enum AccountStatus {
  pending('PENDING', 'Pending'),
  active('ACTIVE', 'Active'),
  inactive('INACTIVE', 'Inactive'),
  suspended('SUSPENDED', 'Suspended'),
  rejected('REJECTED', 'Rejected');

  final String key;
  final String displayName;

  const AccountStatus(this.key, this.displayName);

  static AccountStatus? fromKey(String key) {
    try {
      return AccountStatus.values.firstWhere((e) => e.key == key);
    } catch (_) {
      return null;
    }
  }
}

/// Document format
enum DocumentFormat {
  pdf('PDF'),
  image('IMAGE'),
  file('FILE');

  final String key;

  const DocumentFormat(this.key);
}
