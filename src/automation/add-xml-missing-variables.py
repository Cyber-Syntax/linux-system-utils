import os
from copy import deepcopy

from lxml import etree


def parse_text_elements(xml_path):
    tree = etree.parse(xml_path)
    root = tree.getroot()
    texts_elem = root.find("texts")
    if texts_elem is None:
        raise RuntimeError(f"No <texts> found in {xml_path}")
    mapping = {
        te.get("name"): te for te in texts_elem.findall("text") if te.get("name")
    }
    return tree, texts_elem, mapping


def sync_translations(master_xml_path, target_xml_path, out_xml_path):
    master_tree, master_texts, master_map = parse_text_elements(master_xml_path)
    target_tree, target_texts, target_map = parse_text_elements(target_xml_path)

    # Create a deep copy of master's texts element to preserve structure and comments
    new_texts = deepcopy(master_texts)

    # Update text attributes with translations where available
    for text_elem in new_texts.findall("text"):
        name = text_elem.get("name")
        if name in target_map:
            text_elem.set("text", target_map[name].get("text"))

    # Replace the target's texts element entirely to preserve indentation
    parent = target_texts.getparent()
    parent.replace(target_texts, new_texts)

    # Write out without pretty printing to preserve exact formatting
    target_tree.write(
        out_xml_path, encoding="utf-8", xml_declaration=False, pretty_print=False
    )


def sync_folder(master_xml_path, translations_dir, output_dir):
    """
    master_xml_path: full path to master (e.g. /path/to/en.xml)
    translations_dir: directory containing other xmls
    output_dir: where to write updated xmls (you can overwrite or keep separate)
    """
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    master_basename = os.path.basename(master_xml_path)
    for fname in os.listdir(translations_dir):
        if not fname.lower().endswith(".xml"):
            continue
        if fname == master_basename:
            continue  # Skip the master file to avoid overwriting it
        target_path = os.path.join(translations_dir, fname)
        out_path = os.path.join(output_dir, fname)
        sync_translations(master_xml_path, target_path, out_path)
        print(f"Synced {fname} → {out_path}")


if __name__ == "__main__":
    # Example usage:
    master = "/home/developer/Documents/global-repos/FS25_RealisticLivestock/translations/translation_en.xml"
    translations_folder = (
        "/home/developer/Documents/global-repos/FS25_RealisticLivestock/translations"
    )
    output_folder = (
        "/home/developer/Documents/global-repos/FS25_RealisticLivestock/translations"
    )

    sync_folder(master, translations_folder, output_folder)
