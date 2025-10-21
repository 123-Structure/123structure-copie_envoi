#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de test pour valider les patterns de noms de fichiers
"""

import re

def clean_filename(stem):
    """
    Nettoie le nom de fichier en supprimant 'original' au début ou à la fin
    """
    # Pattern pour capturer "original" au début ou à la fin avec séparateurs
    # Début: original[_-] ou ORIGINAL[_-]
    # Fin: [_-]original ou [_-]ORIGINAL
    clean_stem = re.sub(r'^(original|ORIGINAL)[_-]|[_-](original|ORIGINAL)$', '', stem, flags=re.IGNORECASE)
    
    # Si aucun pattern trouvé, essayer sans séparateurs (cas edge)
    if clean_stem == stem:
        clean_stem = re.sub(r'^(original|ORIGINAL)|[_-]?(original|ORIGINAL)$', '', stem, flags=re.IGNORECASE)
    
    return clean_stem

# Tests avec différents patterns
test_cases = [
    # Cas au début avec séparateurs
    "original_document",
    "ORIGINAL_rapport", 
    "original-facture",
    "ORIGINAL-contrat",
    
    # Cas à la fin avec séparateurs
    "document_original",
    "rapport_ORIGINAL",
    "facture-original", 
    "contrat-ORIGINAL",
    
    # Cas sans séparateurs (edge cases)
    "original",
    "ORIGINAL",
    "documentoriginal",  # Ne devrait pas être modifié
    "originaldocument",  # Ne devrait pas être modifié
    
    # Cas mixtes
    "mon_document_original",
    "ORIGINAL_mon_rapport",
    "test-original",
    "original-test",
]

print("🧪 Test des patterns de nettoyage de noms de fichiers\n")
print(f"{'Nom original':<25} → {'Nom nettoyé':<25}")
print("-" * 55)

for test_case in test_cases:
    result = clean_filename(test_case)
    status = "✅" if result != test_case else "⚠️"
    print(f"{test_case:<25} → {result:<25} {status}")

print("\n📋 Légende:")
print("✅ = Fichier modifié (pattern détecté)")
print("⚠️ = Fichier non modifié (aucun pattern détecté)")