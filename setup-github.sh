#!/bin/bash
# Script para subir la documentación a GitHub

echo "🚀 Pravia Platform Documentation - GitHub Setup"
echo "================================================"
echo ""

# 1. Inicializar repositorio Git
echo "📦 Step 1: Initializing Git repository..."
git init

# 2. Agregar todos los archivos
echo "📝 Step 2: Adding all files..."
git add .

# 3. Crear commit inicial
echo "💾 Step 3: Creating initial commit..."
git commit -m "docs: Initial complete documentation

- Platform Architecture Guide (Markdown + Word)
- Component documentation (12 folders)
- 150+ documentation files
- Complete project structure
- Version 1.0.0"

# 4. Crear rama main
echo "🌿 Step 4: Creating main branch..."
git branch -M main

# 5. Instrucciones para agregar remote
echo ""
echo "✅ Git repository initialized!"
echo ""
echo "📋 Next steps:"
echo "1. Create a new repository on GitHub: https://github.com/new"
echo "   - Name: pravia-platform-docs"
echo "   - Description: Comprehensive architecture and development documentation for Pravia CRM Platform"
echo "   - Visibility: Private (recommended) or Public"
echo "   - DO NOT initialize with README, .gitignore, or license"
echo ""
echo "2. Run these commands (replace YOUR_USERNAME and YOUR_REPO):"
echo ""
echo "   git remote add origin https://github.com/YOUR_USERNAME/pravia-platform-docs.git"
echo "   git push -u origin main"
echo ""
echo "3. Or use SSH (recommended):"
echo ""
echo "   git remote add origin git@github.com:YOUR_USERNAME/pravia-platform-docs.git"
echo "   git push -u origin main"
echo ""
echo "🎉 Done! Your documentation will be live on GitHub!"
