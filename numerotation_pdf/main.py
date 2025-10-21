#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script Python - Numérotation PDF
Ajoute automatiquement une numérotation de pages 1/x à un fichier PDF
Auteur: Baptiste LECHAT
Version: 1.0
"""

import sys
import io
from pathlib import Path
from pypdf import PdfReader, PdfWriter
from reportlab.pdfgen import canvas
from reportlab.lib.units import mm
import re

def show_message(message, title="Numérotation PDF", is_error=False):
    """Affiche un message à l'utilisateur (console uniquement pour l'exe)"""
    prefix = "[ERREUR]" if is_error else "[INFO]"
    print(f"{prefix} {message}")

def write_log(message):
    """Écrit un message de log avec timestamp"""
    from datetime import datetime
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    log_message = f"[{timestamp}] {message}"
    print(log_message)
    
    # # Écriture dans un fichier de log pour debug
    # try:
    #     with open("pdf_numerotation.log", "a", encoding="utf-8") as f:
    #         f.write(log_message + "\n")
    # except Exception:
    #     pass  # Ignore les erreurs de log

def add_page_numbers(input_path):
    """
    Ajoute la numérotation aux pages d'un PDF
    
    Args:
        input_path (str): Chemin vers le fichier PDF d'entrée
        
    Returns:
        bool: True si succès, False sinon
    """
    try:
        input_path = Path(input_path)
        
        # Vérification de l'existence du fichier
        if not input_path.exists():
            show_message(f"Le fichier source n'existe pas.\nChemin : {input_path}", is_error=True)
            return False
            
        # Vérification de l'extension PDF
        if input_path.suffix.lower() != '.pdf':
            show_message(f"Le fichier doit être un PDF.\nFichier : {input_path.name}", is_error=True)
            return False
        
        # Vérification du nom contenant "_original" ou "ORIGINAL-"
        if "original" not in input_path.stem.lower():
            show_message(f"Le fichier ne contient pas 'original' dans son nom.\nFichier : {input_path.name}\n\nLe fichier doit contenir 'original' (au début ou à la fin) pour être traité.", is_error=True)
            return False
        
        # Définition du chemin de sortie - suppression intelligente d'original
        stem = input_path.stem
        # Pattern pour capturer "original" au début ou à la fin avec séparateurs
        # Début: original[_-] ou ORIGINAL[_-]
        # Fin: [_-]original ou [_-]ORIGINAL
        clean_stem = re.sub(r'^(original|ORIGINAL)[_-]|[_-](original|ORIGINAL)$', '', stem, flags=re.IGNORECASE)
        
        # Si aucun pattern trouvé, essayer sans séparateurs (cas edge)
        if clean_stem == stem:
            clean_stem = re.sub(r'^(original|ORIGINAL)|[_-]?(original|ORIGINAL)$', '', stem, flags=re.IGNORECASE)
        
        output_path = input_path.with_name(clean_stem + ".pdf")
        
        write_log(f"Fichier source : {input_path}")
        write_log(f"Fichier destination : {output_path}")
        
        # Lecture du PDF source
        reader = PdfReader(str(input_path))
        writer = PdfWriter()
        total_pages = len(reader.pages)
        
        write_log(f"Nombre total de pages : {total_pages}")
        
        # Traitement de chaque page
        for i, page in enumerate(reader.pages, start=1):
            write_log(f"Traitement de la page {i}/{total_pages}")
            
            # Création du calque de numérotation
            packet = io.BytesIO()
            
            # Récupération des dimensions de la page
            page_width = float(page.mediabox.width)
            page_height = float(page.mediabox.height)
            
            # Création du canvas pour la numérotation
            can = canvas.Canvas(packet, pagesize=(page_width, page_height))
            
            # Texte de numérotation
            text = f"{i}/{total_pages}"
            
            # Position : 10mm du bord droit et du bord bas
            x = page_width - 10 * mm
            y = 10 * mm
            
            # Configuration de la police (utiliser Helvetica qui est toujours disponible)
            can.setFont("Helvetica", 11)
            
            # Ajout du texte aligné à droite
            can.drawRightString(x, y, text)
            can.save()
            
            # Fusion du calque avec la page
            packet.seek(0)
            overlay = PdfReader(packet)
            number_layer = overlay.pages[0]
            
            page.merge_page(number_layer)
            writer.add_page(page)
        
        # Sauvegarde du fichier final
        with open(output_path, "wb") as f:
            writer.write(f)
        
        # Vérification de la création du fichier
        if output_path.exists():
            file_size = output_path.stat().st_size / (1024 * 1024)  # Taille en MB
            success_msg = f"Numérotation réussie !\n\nFichier source :\n{input_path}\n\nFichier généré :\n{output_path}\n\nTaille : {file_size:.2f} MB\nPages numérotées : {total_pages}"
            write_log("Numérotation terminée avec succès")
            show_message(success_msg)
            return True
        else:
            show_message("Erreur lors de la sauvegarde du fichier numéroté", is_error=True)
            return False
            
    except Exception as e:
        error_msg = f"Erreur lors de la numérotation !\n\nFichier source :\n{input_path}\n\nErreur :\n{str(e)}"
        write_log(f"Erreur : {str(e)}")
        show_message(error_msg, is_error=True)
        return False

def safe_input(prompt=""):
    """Fonction sécurisée pour input() qui évite l'erreur RuntimeError: lost sys.stdin"""
    try:
        if hasattr(sys.stdin, 'isatty') and sys.stdin.isatty():
            return input(prompt)
        else:
            # Pas de stdin disponible, on attend juste un peu
            import time
            time.sleep(3)
            return ""
    except (RuntimeError, OSError):
        # Erreur stdin, on attend juste un peu
        import time
        time.sleep(3)
        return ""

def main():
    """Fonction principale du script"""
    write_log("Démarrage du script de numérotation PDF")
    
    # Vérification des arguments
    if len(sys.argv) < 2:
        show_message("Utilisation : main.exe <fichier.pdf>\n\nLe fichier doit contenir 'original' ou 'ORIGINAL' dans son nom.", is_error=True)
        safe_input("Appuyez sur Entrée pour fermer...")
        return 1
    
    file_path = sys.argv[1]
    write_log(f"Fichier à traiter : {file_path}")
    
    # Traitement du fichier
    success = add_page_numbers(file_path)
    
    if success:
        write_log("Script terminé avec succès")
        print("\n[INFO] Fermeture automatique dans 2 secondes...")
        import time
        time.sleep(2)
        return 0
    else:
        write_log("Script terminé avec des erreurs")
        safe_input("\nAppuyez sur Entrée pour fermer...")
        return 1

if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)