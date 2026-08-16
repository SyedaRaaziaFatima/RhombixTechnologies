import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/app_config.dart';
import '../core/app_theme.dart';
import '../data/app_controller.dart';
import '../data/models.dart';
import '../main.dart';

String money(num value) => 'Rs ${value.toStringAsFixed(0)}';

void showError(BuildContext context, Object error) {
  final message = error.toString().replaceFirst('Exception: ', '');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: AppColors.danger),
  );
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return controller.isAuthenticated ? const MainShell() : const AuthScreen();
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController(text: 'demo@bazaarhub.pk');
  final _password = TextEditingController(text: '123456');
  bool _signup = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final controller = AppScope.of(context);
      if (_signup) {
        await controller.signUp(_name.text, _email.text, _password.text);
      } else {
        await controller.signIn(_email.text, _password.text);
      }
    } catch (error) {
      if (mounted) showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const GoldLogo(size: 84),
                    const SizedBox(height: 20),
                    const Text(
                      'BazaarHub',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.sapphire,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      'Buy smart. Sell securely.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: .68),
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (!AppConfig.hasSupabase)
                      const DemoModeBanner(),
                    if (_signup) ...[
                      TextFormField(
                        controller: _name,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Full name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) => (value?.trim().length ?? 0) < 2
                            ? 'Apna naam likhein'
                            : null,
                      ),
                      const SizedBox(height: 14),
                    ],
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                      validator: (value) => !(value?.contains('@') ?? false)
                          ? 'Valid email likhein'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _password,
                      obscureText: _hidePassword,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _hidePassword = !_hidePassword,
                          ),
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) => (value?.length ?? 0) < 6
                          ? 'Password kam az kam 6 characters ho'
                          : null,
                    ),
                    const SizedBox(height: 22),
                    FilledButton(
                      onPressed: controller.busy ? null : _submit,
                      child: controller.busy
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_signup ? 'CREATE ACCOUNT' : 'LOGIN'),
                    ),
                    TextButton(
                      onPressed: controller.busy
                          ? null
                          : () => setState(() => _signup = !_signup),
                      child: Text(
                        _signup
                            ? 'Already registered? Login'
                            : 'New to BazaarHub? Create account',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    const pages = [
      HomeScreen(),
      SellScreen(),
      OrdersScreen(),
      ProfileScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.add_box_outlined),
            selectedIcon: Icon(Icons.add_box),
            label: 'Sell',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: controller.cartCount > 0,
              label: Text('${controller.cartCount}'),
              child: const Icon(Icons.person_outline),
            ),
            selectedIcon: const Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const GoldLogo(size: 38),
            const SizedBox(width: 10),
            Text(
              'BazaarHub',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Cart',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const CartScreen()),
            ),
            icon: Badge(
              isLabelVisible: controller.cartCount > 0,
              label: Text('${controller.cartCount}'),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.initialize,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              sliver: SliverList.list(
                children: [
                  Text(
                    'Hello, ${controller.user?.name ?? 'Shopper'} 👋',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Find something worth buying today.',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    onChanged: controller.search,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        tooltip: 'Price filter',
                        onPressed: () => showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => _PriceFilterSheet(
                            controller: controller,
                          ),
                        ),
                        icon: Badge(
                          isLabelVisible: controller.hasPriceFilter,
                          child: const Icon(Icons.tune),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const _HeroOffer(),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final category = controller.categories[index];
                        return ChoiceChip(
                          selectedColor: AppColors.gold,
                          labelStyle: TextStyle(
                            color: controller.category == category
                                ? Colors.black
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                          label: Text(category),
                          selected: controller.category == category,
                          onSelected: (_) =>
                              controller.selectCategory(category),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Popular products',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      Text(
                        '${controller.products.length} items',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            if (controller.products.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.search_off,
                  title: 'No products found',
                  message: 'Search ya category change karke dobara dekhein.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: .62,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: controller.products.length,
                  itemBuilder: (_, index) =>
                      ProductCard(product: controller.products[index]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeroOffer extends StatelessWidget {
  const _HeroOffer();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF151006), Color(0xFF6C5314), Color(0xFF211804)],
        ),
        border: Border.all(color: const Color(0xB3FFD45C)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'GLITTER DEALS',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Buy & sell with confidence',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Secure accounts • Protected orders',
                  style: TextStyle(color: Colors.white.withValues(alpha: .86)),
                ),
              ],
            ),
          ),
          const Icon(Icons.auto_awesome, size: 70, color: Colors.white),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final favorite = controller.favorites.contains(product.id);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ProductImage(url: product.imageUrl),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        onPressed: () =>
                            controller.toggleFavorite(product.id),
                        iconSize: 20,
                        icon: Icon(
                          favorite ? Icons.favorite : Icons.favorite_border,
                          color: favorite ? AppColors.gold : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        product.condition == ProductCondition.newItem
                            ? 'NEW'
                            : 'USED',
                        style: const TextStyle(
                          color: AppColors.lightGold,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 5),
              child: Text(
                product.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                money(product.price),
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 3, 8, 8),
              child: SizedBox(
                height: 36,
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    controller.addToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added to cart')),
                    );
                  },
                  icon: const Icon(Icons.add_shopping_cart, size: 17),
                  label: const Text('ADD'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(product.title)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 110),
        children: [
          AspectRatio(
            aspectRatio: 1.15,
            child: Hero(
              tag: 'product-${product.id}',
              child: ProductImage(url: product.imageUrl),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          controller.toggleFavorite(product.id),
                      icon: Icon(
                        controller.favorites.contains(product.id)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
                Text(
                  money(product.price),
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(label: Text(product.category)),
                    Chip(label: Text('${product.stock} in stock')),
                    Chip(
                      label: Text(
                        product.condition == ProductCondition.newItem
                            ? 'New condition'
                            : 'Used condition',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: .72),
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  tileColor: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.gold,
                    child: Icon(Icons.store, color: Colors.black),
                  ),
                  title: Text(product.sellerName),
                  subtitle: const Text('Verified marketplace seller'),
                  trailing: const Icon(Icons.verified, color: AppColors.gold),
                ),
                const SizedBox(height: 24),
                ProductReviews(productId: product.id),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton.icon(
            onPressed: () {
              controller.addToCart(product);
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const CartScreen()),
              );
            },
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text('ADD TO CART'),
          ),
        ),
      ),
    );
  }
}

class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController(text: '1');
  String _category = 'Electronics';
  ProductCondition _condition = ProductCondition.newItem;
  Uint8List? _image;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _price.dispose();
    _stock.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 78,
        maxWidth: 1600,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        if (bytes.length > 5 * 1024 * 1024) {
          throw Exception('Image 5 MB se choti honi chahiye.');
        }
        setState(() => _image = bytes);
      }
    } catch (error) {
      if (mounted) showError(context, error);
    }
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = AppScope.of(context);
    final user = controller.user!;
    try {
      await controller.addProduct(
        Product(
          id: '',
          sellerId: user.id,
          sellerName: user.name,
          title: _title.text.trim(),
          description: _description.text.trim(),
          category: _category,
          price: double.parse(_price.text),
          imageUrl: '',
          condition: _condition,
          stock: int.parse(_stock.text),
        ),
        _image,
      );
      if (!mounted) return;
      _formKey.currentState!.reset();
      _title.clear();
      _description.clear();
      _price.clear();
      _stock.text = '1';
      setState(() => _image = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product published successfully.')),
      );
    } catch (error) {
      if (mounted) showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    const categories = ['Electronics', 'Fashion', 'Shoes', 'Home', 'Beauty', 'Other'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sell a product'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const MyProductsScreen()),
            ),
            child: Text('My listings (${controller.myProducts.length})'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            InkWell(
              onTap: _pickImage,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 210,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.gold.withValues(alpha: .5)),
                ),
                child: _image == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 54,
                            color: AppColors.gold,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Add product photo',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            'JPG/PNG • Maximum 5 MB',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: .68),
                            ),
                          ),
                        ],
                      )
                    : Image.memory(_image!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _title,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Product title'),
              validator: (value) => (value?.trim().length ?? 0) < 3
                  ? 'Product title likhein'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              minLines: 4,
              maxLines: 6,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) => (value?.trim().length ?? 0) < 10
                  ? 'Kam az kam 10 characters ki description likhein'
                  : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: categories
                  .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) => setState(() => _category = value!),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _price,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Price (PKR)'),
                    validator: (value) {
                      final price = double.tryParse(value ?? '');
                      return price == null || price <= 0 ? 'Invalid price' : null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _stock,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Stock'),
                    validator: (value) {
                      final stock = int.tryParse(value ?? '');
                      return stock == null || stock < 1 ? 'Invalid' : null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SegmentedButton<ProductCondition>(
              segments: const [
                ButtonSegment(
                  value: ProductCondition.newItem,
                  label: Text('New'),
                  icon: Icon(Icons.fiber_new),
                ),
                ButtonSegment(
                  value: ProductCondition.used,
                  label: Text('Used'),
                  icon: Icon(Icons.recycling),
                ),
              ],
              selected: {_condition},
              onSelectionChanged: (value) =>
                  setState(() => _condition = value.first),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: controller.busy ? null : _publish,
              icon: const Icon(Icons.publish),
              label: Text(controller.busy ? 'PUBLISHING...' : 'PUBLISH PRODUCT'),
            ),
          ],
        ),
      ),
    );
  }
}

class MyProductsScreen extends StatelessWidget {
  const MyProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('My listings')),
      body: controller.myProducts.isEmpty
          ? const EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No listings yet',
              message: 'Sell tab se apna pehla product publish karein.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: controller.myProducts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final product = controller.myProducts[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: SizedBox.square(
                      dimension: 64,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: ProductImage(url: product.imageUrl),
                      ),
                    ),
                    title: Text(product.title),
                    subtitle: Text('${money(product.price)} • ${product.stock} stock'),
                    trailing: IconButton(
                      tooltip: 'Delete',
                      onPressed: () => controller.deleteProduct(product.id),
                      icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final lines = controller.cartLines;
    return Scaffold(
      appBar: AppBar(title: Text('Cart (${controller.cartCount})')),
      body: lines.isEmpty
          ? const EmptyState(
              icon: Icons.remove_shopping_cart_outlined,
              title: 'Your cart is empty',
              message: 'Home se pasand ka product cart mein add karein.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 190),
              itemCount: lines.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final line = lines[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox.square(
                            dimension: 78,
                            child: ProductImage(url: line.product.imageUrl),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                line.product.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                              Text(
                                money(line.total),
                                style: const TextStyle(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Row(
                                children: [
                                  _QuantityButton(
                                    icon: Icons.remove,
                                    onTap: () => controller.changeQuantity(
                                      line.product,
                                      -1,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 38,
                                    child: Text(
                                      '${line.quantity}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  _QuantityButton(
                                    icon: Icons.add,
                                    onTap: () => controller.changeQuantity(
                                      line.product,
                                      1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomSheet: lines.isEmpty
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: const Border(
                    top: BorderSide(color: Color(0x66FFD45C)),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PriceRow(label: 'Subtotal', value: controller.cartSubtotal),
                    const _PriceRow(label: 'Delivery', value: 0, free: true),
                    const Divider(height: 22),
                    _PriceRow(
                      label: 'Total',
                      value: controller.cartSubtotal,
                      emphasized: true,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const CheckoutScreen(),
                        ),
                      ),
                      child: const Text('PROCEED TO CHECKOUT'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _address = TextEditingController();
  String _payment = 'Cash on Delivery';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_address.text.isEmpty) {
      _address.text = AppScope.of(context).user?.address ?? '';
    }
  }

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_address.text.trim().length < 10) {
      showError(context, Exception('Complete delivery address likhein.'));
      return;
    }
    final controller = AppScope.of(context);
    try {
      final order = await controller.checkout(_address.text.trim(), _payment);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: AppColors.gold, size: 58),
          title: const Text('Order confirmed!'),
          content: Text(
            'Order ${order.id} successfully place ho gaya.\n\nPayment: $_payment',
            textAlign: TextAlign.center,
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('DONE'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (error) {
      if (mounted) showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Secure checkout')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionTitle(icon: Icons.local_shipping_outlined, title: 'Delivery address'),
          TextField(
            controller: _address,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'House, street, city and phone details',
            ),
          ),
          const SizedBox(height: 24),
          const _SectionTitle(icon: Icons.shield_outlined, title: 'Payment method'),
          RadioListTile<String>(
            value: 'Cash on Delivery',
            groupValue: _payment,
            onChanged: (value) => setState(() => _payment = value!),
            title: const Text('Cash on Delivery'),
            subtitle: const Text('Pay when your order arrives'),
            secondary: const Icon(Icons.payments_outlined),
          ),
          RadioListTile<String>(
            value: 'Demo Card Payment',
            groupValue: _payment,
            onChanged: (value) => setState(() => _payment = value!),
            title: const Text('Demo card payment'),
            subtitle: const Text('Assignment sandbox — no real money charged'),
            secondary: const Icon(Icons.credit_card),
          ),
          if (_payment == 'Demo Card Payment')
            const Card(
              child: ListTile(
                leading: Icon(Icons.science_outlined, color: AppColors.gold),
                title: Text('Test payment approved'),
                subtitle: Text(
                  'This demonstrates a safe server-confirmed checkout. Live keys are never stored in the app.',
                ),
              ),
            ),
          const SizedBox(height: 24),
          const _SectionTitle(icon: Icons.receipt_outlined, title: 'Order summary'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _PriceRow(label: '${controller.cartCount} items', value: controller.cartSubtotal),
                  const _PriceRow(label: 'Delivery', value: 0, free: true),
                  const Divider(height: 26),
                  _PriceRow(
                    label: 'Payable total',
                    value: controller.cartSubtotal,
                    emphasized: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: controller.busy ? null : _placeOrder,
            icon: const Icon(Icons.lock_outline),
            label: Text(controller.busy ? 'PROCESSING...' : 'PLACE SECURE ORDER'),
          ),
          const SizedBox(height: 8),
          Text(
            'Your account and order data are protected by database security policies.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: .68),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('My orders')),
      body: controller.orders.isEmpty
          ? const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No orders yet',
              message: 'Your confirmed purchases will appear here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: controller.orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final order = controller.orders[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                order.id,
                                style: const TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: .16),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                order.status.name.toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.lightGold,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Text('${order.items.length} product type(s) • ${order.paymentMethod}'),
                        const SizedBox(height: 6),
                        Text(
                          money(order.total),
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _pickProfileImage(BuildContext context) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (picked == null || !context.mounted) return;
      final bytes = await picked.readAsBytes();
      if (bytes.length > 5 * 1024 * 1024) {
        throw Exception('Profile image 5 MB se choti honi chahiye.');
      }
      await AppScope.of(context).uploadProfileImage(bytes);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo updated.')),
        );
      }
    } catch (error) {
      if (context.mounted) showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final user = controller.user!;
    final ImageProvider<Object>? avatarProvider = controller.avatarBytes != null
        ? MemoryImage(controller.avatarBytes!)
        : user.avatarUrl.isNotEmpty
            ? NetworkImage(user.avatarUrl)
            : null;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.sky,
                  backgroundImage: avatarProvider,
                  child: avatarProvider == null
                      ? Text(
                          user.name.isEmpty
                              ? 'U'
                              : user.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  right: -5,
                  bottom: -2,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.sky,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      tooltip: 'Upload profile photo',
                      onPressed: controller.busy
                          ? null
                          : () => _pickProfileImage(context),
                      icon: const Icon(
                        Icons.camera_alt_outlined,
                        color: Color(0xFF03111C),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            user.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          Text(
            user.email,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: .68),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.shopping_bag_outlined),
                  title: const Text('Shopping cart'),
                  trailing: Text('${controller.cartCount}'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const CartScreen()),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: const Text('My product listings'),
                  trailing: Text('${controller.myProducts.length}'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const MyProductsScreen()),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.favorite_border),
                  title: const Text('Saved products'),
                  trailing: Text('${controller.favorites.length}'),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: Icon(
                    controller.darkMode
                        ? Icons.dark_mode
                        : Icons.auto_awesome,
                  ),
                  title: const Text('Dark mode'),
                  subtitle: const Text('Switch glitter theme brightness'),
                  value: controller.darkMode,
                  onChanged: controller.toggleDarkMode,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.verified_user_outlined, color: AppColors.gold),
                  title: Text('Secure account'),
                  subtitle: Text('Protected by Supabase Auth and RLS'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.help_outline),
                  title: Text('Help & support'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: controller.signOut,
            icon: const Icon(Icons.logout),
            label: const Text('LOGOUT'),
          ),
        ],
      ),
    );
  }
}

class _PriceFilterSheet extends StatefulWidget {
  const _PriceFilterSheet({required this.controller});

  final AppController controller;

  @override
  State<_PriceFilterSheet> createState() => _PriceFilterSheetState();
}

class _PriceFilterSheetState extends State<_PriceFilterSheet> {
  late final double _maximum;
  late RangeValues _range;

  @override
  void initState() {
    super.initState();
    _maximum = widget.controller.highestPrice < 100
        ? 100
        : widget.controller.highestPrice.ceilToDouble();
    final start = (widget.controller.minPrice ?? 0).clamp(0, _maximum);
    final end = (widget.controller.maxPrice ?? _maximum).clamp(start, _maximum);
    _range = RangeValues(start.toDouble(), end.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.tune, color: AppColors.sky),
                SizedBox(width: 10),
                Text(
                  'Filter by price',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  money(_range.start),
                  style: const TextStyle(
                    color: AppColors.sky,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  money(_range.end),
                  style: const TextStyle(
                    color: AppColors.sky,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            RangeSlider(
              min: 0,
              max: _maximum,
              divisions: 20,
              values: _range,
              labels: RangeLabels(
                money(_range.start),
                money(_range.end),
              ),
              onChanged: (value) => setState(() => _range = value),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      widget.controller.clearPriceFilter();
                      Navigator.of(context).pop();
                    },
                    child: const Text('CLEAR'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      widget.controller.setPriceRange(
                        _range.start <= 0 ? null : _range.start,
                        _range.end >= _maximum ? null : _range.end,
                      );
                      Navigator.of(context).pop();
                    },
                    child: const Text('APPLY'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProductReviews extends StatefulWidget {
  const ProductReviews({required this.productId, super.key});

  final String productId;

  @override
  State<ProductReviews> createState() => _ProductReviewsState();
}

class _ProductReviewsState extends State<ProductReviews> {
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requested) return;
    _requested = true;
    Future<void>(() async {
      try {
        await AppScope.of(context).loadReviews(widget.productId);
      } catch (error) {
        if (mounted) showError(context, error);
      }
    });
  }

  Future<void> _addReview() async {
    final comment = TextEditingController();
    var rating = 5;
    final draft = await showDialog<_ReviewDraft>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Rate this product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final value = index + 1;
                  return IconButton(
                    onPressed: () => setDialogState(() => rating = value),
                    icon: Icon(
                      value <= rating ? Icons.star : Icons.star_border,
                      color: AppColors.sky,
                    ),
                  );
                }),
              ),
              TextField(
                controller: comment,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Your review',
                  hintText: 'Product kaisa laga?',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('CANCEL'),
            ),
            FilledButton(
              onPressed: () {
                if (comment.text.trim().length < 3) return;
                Navigator.of(dialogContext).pop(
                  _ReviewDraft(rating, comment.text.trim()),
                );
              },
              child: const Text('SUBMIT'),
            ),
          ],
        ),
      ),
    );
    comment.dispose();
    if (draft == null || !mounted) return;
    try {
      await AppScope.of(context).submitReview(
        productId: widget.productId,
        rating: draft.rating,
        comment: draft.comment,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review saved.')),
        );
      }
    } catch (error) {
      if (mounted) showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final reviews = controller.reviewsFor(widget.productId);
    final average = controller.averageRating(widget.productId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Reviews & ratings',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
              ),
            ),
            if (reviews.isNotEmpty) ...[
              const Icon(Icons.star, color: AppColors.sky, size: 20),
              Text(
                ' ${average.toStringAsFixed(1)} (${reviews.length})',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _addReview,
          icon: const Icon(Icons.rate_review_outlined),
          label: const Text('WRITE A REVIEW'),
        ),
        const SizedBox(height: 10),
        if (reviews.isEmpty)
          Text(
            'No reviews yet. Be the first to rate this product.',
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: .68),
            ),
          )
        else
          ...reviews.map(
            (review) => Card(
              margin: const EdgeInsets.only(bottom: 9),
              child: Padding(
                padding: const EdgeInsets.all(13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            review.userName,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        ...List.generate(
                          5,
                          (index) => Icon(
                            index < review.rating
                                ? Icons.star
                                : Icons.star_border,
                            color: AppColors.sky,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(review.comment),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ReviewDraft {
  const _ReviewDraft(this.rating, this.comment);

  final int rating;
  final String comment;
}

class GoldLogo extends StatelessWidget {
  const GoldLogo({this.size = 48, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const SweepGradient(
          colors: [
            AppColors.gold,
            AppColors.lightGold,
            AppColors.gold,
            Colors.white,
            AppColors.gold,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: .25),
            blurRadius: 18,
          ),
        ],
      ),
      child: Icon(Icons.storefront, color: Colors.white, size: size * .52),
    );
  }
}

class DemoModeBanner extends StatelessWidget {
  const DemoModeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withValues(alpha: .35)),
      ),
      child: const Row(
        children: [
          Icon(Icons.science_outlined, color: AppColors.gold),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Demo mode: pre-filled login use karein. Supabase connect karne par real accounts aur cloud data active ho jayega.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductImage extends StatelessWidget {
  const ProductImage({required this.url, super.key});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const ColoredBox(
        color: AppColors.surfaceHigh,
        child: Icon(Icons.image_not_supported_outlined, size: 44),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : const ColoredBox(
              color: AppColors.surfaceHigh,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
      errorBuilder: (_, __, ___) => const ColoredBox(
        color: AppColors.surfaceHigh,
        child: Icon(Icons.broken_image_outlined, size: 44),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 70, color: AppColors.gold),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: .68),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 17),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.free = false,
    this.emphasized = false,
  });

  final String label;
  final double value;
  final bool free;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: emphasized ? AppColors.lightGold : Colors.white,
      fontSize: emphasized ? 18 : 14,
      fontWeight: emphasized ? FontWeight.w900 : FontWeight.w500,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(free ? 'FREE' : money(value), style: style),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
