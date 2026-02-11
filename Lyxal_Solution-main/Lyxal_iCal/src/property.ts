import type { Component } from "./component";
import type { DesignSet, JCalProperty } from "./types";
import design from "./design";
import ICALParse from "./parse";
import ICALStringify from "./stringify";

const NAME_INDEX = 0;
const PROP_INDEX = 1;
const TYPE_INDEX = 2;
const VALUE_INDEX = 3;

/**
 * Provides a layer on top of the raw jCal object for manipulating a single property.
 */
export class Property {
    jCal: JCalProperty;
    private _parent: Component | null;
    private _values?: unknown[];
    isDecorated: boolean = false;
    isMultiValue: boolean = false;
    isStructuredValue: boolean = false;

    /**
     * Create a Property by parsing the passed iCalendar string.
     */
    static fromString(str: string, designSet?: DesignSet): Property {
        return new Property(ICALParse.property(str, designSet));
    }

    /**
     * Creates a new Property instance.
     */
    constructor(jCal: JCalProperty | string, parent?: Component) {
        this._parent = parent || null;

        if (typeof jCal === 'string') {
            this.jCal = [jCal, {}, design.defaultType] as JCalProperty;
            (this.jCal as any)[TYPE_INDEX] = this.getDefaultType();
        } else {
            this.jCal = jCal;
        }
        this._updateType();
    }

    /**
     * The value type for this property
     */
    get type(): string {
        return (this.jCal as any)[TYPE_INDEX];
    }

    /**
     * The name of this property, in lowercase.
     */
    get name(): string {
        return (this.jCal as any)[NAME_INDEX];
    }

    /**
     * The parent component for this property.
     */
    get parent(): Component | null {
        return this._parent;
    }

    set parent(p: Component | null) {
        const designSetChanged = !this._parent || (p && (p as any)._designSet != (this._parent as any)?._designSet);
        this._parent = p;

        if (this.type == design.defaultType && designSetChanged) {
            (this.jCal as any)[TYPE_INDEX] = this.getDefaultType();
            this._updateType();
        }
    }

    /**
     * The design set for this property
     */
    get _designSet(): DesignSet {
        return this.parent ? (this.parent as any)._designSet : design.defaultSet;
    }

    private _updateType(): void {
        const designSet = this._designSet;

        if (this.type in designSet.value) {
            if ('decorate' in designSet.value[this.type]) {
                this.isDecorated = true;
            } else {
                this.isDecorated = false;
            }

            if (this.name in designSet.property) {
                this.isMultiValue = 'multiValue' in designSet.property[this.name];
                this.isStructuredValue = 'structuredValue' in designSet.property[this.name];
            }
        }
    }

    private _hydrateValue(index: number): unknown {
        if (this._values && this._values[index]) {
            return this._values[index];
        }

        if (this.jCal.length <= (VALUE_INDEX + index)) {
            return null;
        }

        if (this.isDecorated) {
            if (!this._values) {
                this._values = [];
            }
            return (this._values[index] = this._decorate(
                (this.jCal as any)[VALUE_INDEX + index]
            ));
        } else {
            return (this.jCal as any)[VALUE_INDEX + index];
        }
    }

    private _decorate(value: unknown): unknown {
        return this._designSet.value[this.type].decorate!(value, this);
    }

    private _undecorate(value: unknown): unknown {
        return this._designSet.value[this.type].undecorate!(value);
    }

    private _setDecoratedValue(value: unknown, index: number): void {
        if (!this._values) {
            this._values = [];
        }

        if (typeof value === 'object' && value !== null && 'icaltype' in value) {
            (this.jCal as any)[VALUE_INDEX + index] = this._undecorate(value);
            this._values[index] = value;
        } else {
            (this.jCal as any)[VALUE_INDEX + index] = value;
            this._values[index] = this._decorate(value);
        }
    }

    /**
     * Gets a parameter on the property.
     */
    getParameter(name: string): unknown {
        if (name in (this.jCal as any)[PROP_INDEX]) {
            return (this.jCal as any)[PROP_INDEX][name];
        } else {
            return undefined;
        }
    }

    /**
     * Gets first parameter on the property.
     */
    getFirstParameter(name: string): string | undefined {
        const parameters = this.getParameter(name);

        if (Array.isArray(parameters)) {
            return parameters[0];
        }

        return parameters as string | undefined;
    }

    /**
     * Sets a parameter on the property.
     */
    setParameter(name: string, value: string | string[]): void {
        const lcname = name.toLowerCase();
        if (typeof value === "string" &&
            lcname in this._designSet.param &&
            'multiValue' in this._designSet.param[lcname]) {
            value = [value];
        }
        (this.jCal as any)[PROP_INDEX][name] = value;
    }

    /**
     * Removes a parameter
     */
    removeParameter(name: string): void {
        delete (this.jCal as any)[PROP_INDEX][name];
    }

    /**
     * Get the default type based on this property's name.
     */
    getDefaultType(): string {
        const name = (this.jCal as any)[NAME_INDEX];
        const designSet = this._designSet;

        if (name in designSet.property) {
            const details = designSet.property[name];
            if ('defaultType' in details) {
                return details.defaultType;
            }
        }
        return design.defaultType;
    }

    /**
     * Sets type of property and clears out any existing values.
     */
    resetType(type: string): void {
        this.removeAllValues();
        (this.jCal as any)[TYPE_INDEX] = type;
        this._updateType();
    }

    /**
     * Finds the first property value.
     */
    getFirstValue(): unknown {
        return this._hydrateValue(0);
    }

    /**
     * Gets all values on the property.
     */
    getValues(): unknown[] {
        const len = this.jCal.length - VALUE_INDEX;

        if (len < 1) {
            return [];
        }

        const result: unknown[] = [];
        for (let i = 0; i < len; i++) {
            result[i] = this._hydrateValue(i);
        }

        return result;
    }

    /**
     * Removes all values from this property
     */
    removeAllValues(): void {
        if (this._values) {
            this._values.length = 0;
        }
        this.jCal.length = 3;
    }

    /**
     * Sets the values of the property.
     */
    setValues(values: unknown[]): void {
        if (!this.isMultiValue) {
            throw new Error(
                this.name + ': does not not support multiValue.\n' +
                'override isMultiValue'
            );
        }

        const len = values.length;
        this.removeAllValues();

        if (len > 0 &&
            typeof values[0] === 'object' &&
            values[0] !== null &&
            'icaltype' in values[0]) {
            this.resetType((values[0] as any).icaltype);
        }

        if (this.isDecorated) {
            for (let i = 0; i < len; i++) {
                this._setDecoratedValue(values[i], i);
            }
        } else {
            for (let i = 0; i < len; i++) {
                (this.jCal as any)[VALUE_INDEX + i] = values[i];
            }
        }
    }

    /**
     * Sets the current value of the property.
     */
    setValue(value: unknown): void {
        this.removeAllValues();
        if (typeof value === 'object' && value !== null && 'icaltype' in value) {
            this.resetType((value as any).icaltype);
        }

        if (this.isDecorated) {
            this._setDecoratedValue(value, 0);
        } else {
            (this.jCal as any)[VALUE_INDEX] = value;
        }
    }

    /**
     * Returns the Object representation of this component.
     */
    toJSON(): JCalProperty {
        return this.jCal;
    }

    /**
     * The string representation of this component.
     */
    toICALString(): string {
        return ICALStringify.property(this.jCal, this._designSet, true);
    }
}

export default Property;
