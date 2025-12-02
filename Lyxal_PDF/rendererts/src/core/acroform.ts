import { Dict, Name, Ref } from './primitives';
import { XRef } from './xref';
import { AnnotationFactory } from './annotation';

export class PDFForm {
    xref: XRef;
    catalog: Dict;
    formDict: Dict | null = null;
    fields: any[] = [];
    hasFields: boolean = false;

    constructor(xref: XRef, catalog: Dict) {
        this.xref = xref;
        this.catalog = catalog;
    }

    async parse() {
        this.formDict = this.catalog.get("AcroForm");
        if (!this.formDict) return;

        // Check XFA
        const xfa = this.formDict.get("XFA");
        if (xfa) {
            console.log("XFA Forms not fully supported, falling back to AcroForm");
        }

        const fields = this.formDict.get("Fields");
        if (Array.isArray(fields)) {
            this.hasFields = true;
            for (const ref of fields) {
                await this.parseField(ref, null);
            }
        }
    }

    async parseField(ref: any, parent: any) {
        let dict = ref;
        if (ref instanceof Ref) {
            dict = await this.xref.fetchAsync(ref);
        }

        if (!(dict instanceof Dict)) return;

        // Resolve inheritance
        if (parent) {
            // Inheritable fields: FT, V, DV, AA, DA, Q, Opt, TI, I, TM
            const inheritable = ["FT", "V", "DV", "AA", "DA", "Q", "Opt", "TI", "I", "TM"];
            for (const key of inheritable) {
                if (!dict.has(key) && parent.has(key)) {
                    dict.set(key, parent.get(key));
                }
            }
        }

        // Field Name (T)
        // Partial name. Full name is Parent.T + . + T
        let partialName = dict.get("T");
        let fullName = partialName;
        if (parent && parent.fullName) {
             fullName = partialName ? `${parent.fullName}.${partialName}` : parent.fullName;
        }
        
        // Store metadata on dict for easier access later
        // This is a bit hacky, modifying the dict, but efficient
        (dict as any).fullName = fullName;

        const type = dict.get("FT");
        const typeName = type instanceof Name ? type.name : null;
        
        // If it has a Type, it's a terminal field (usually), unless it has Kids that are also widgets?
        // Actually, intermediate nodes can have T but no FT if they are just grouping.
        
        const fieldObj = {
            ref: ref instanceof Ref ? ref : null,
            dict: dict,
            name: fullName,
            type: typeName,
            value: dict.get("V"),
            kids: [] as any[]
        };

        this.fields.push(fieldObj);

        // Kids
        const kids = dict.get("Kids");
        if (Array.isArray(kids)) {
            for (const kidRef of kids) {
                const kid = await this.parseField(kidRef, dict);
                if (kid) fieldObj.kids.push(kid);
            }
        }
        
        return fieldObj;
    }
}

