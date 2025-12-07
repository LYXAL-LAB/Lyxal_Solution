import { Property } from "./property";
import type { DesignSet, JCalComponent } from "./types";
import design from "./design";
import ICALParse from "./parse";
import stringify from "./stringify";
import Timezone from "./timezone";

const NAME_INDEX = 0;
const PROPERTY_INDEX = 1;
const COMPONENT_INDEX = 2;
const PROPERTY_NAME_INDEX = 0;
const PROPERTY_VALUE_INDEX = 3;

function getDesign() {
    return design;
}

/**
 * Wraps a jCal component, adding convenience methods to add, remove and 
 * update subcomponents and properties.
 */
export class Component {
    jCal: JCalComponent;
    parent: Component | null = null;

    private _hydratedPropertyCount: number = 0;
    private _hydratedComponentCount: number = 0;
    private _timezoneCache: Map<string, any> | null = null;
    private _components: Component[] | null = null;
    private _properties: Property[] | null = null;

    /**
     * Create a Component by parsing the passed iCalendar string.
     */
    static fromString(str: string): Component {
        return new Component(ICALParse.component(str));
    }

    /**
     * Creates a new Component instance.
     */
    constructor(jCal: JCalComponent | string, parent?: Component) {
        if (typeof jCal === 'string') {
            jCal = [jCal, [], []] as JCalComponent;
        }

        this.jCal = jCal;
        this.parent = parent || null;

        if (!this.parent && this.name === 'vcalendar') {
            this._timezoneCache = new Map();
        }
    }

    /**
     * The name of this component
     */
    get name(): string {
        return this.jCal[NAME_INDEX];
    }

    /**
     * The design set for this component
     */
    get _designSet(): DesignSet {
        const d = getDesign();
        const parentDesign = this.parent && (this.parent as any)._designSet;

        if (!parentDesign && this.name == "vcard") {
            const versionProp = this.jCal[PROPERTY_INDEX]?.[0];
            if (versionProp &&
                versionProp[PROPERTY_NAME_INDEX] == "version" &&
                versionProp[PROPERTY_VALUE_INDEX] == "3.0") {
                return d.getDesignSet("vcard3");
            }
        }

        return parentDesign || d.getDesignSet(this.name);
    }

    private _hydrateComponent(index: number): Component {
        if (!this._components) {
            this._components = [];
            this._hydratedComponentCount = 0;
        }

        if (this._components[index]) {
            return this._components[index];
        }

        const comp = new Component(
            this.jCal[COMPONENT_INDEX][index],
            this
        );

        this._hydratedComponentCount++;
        return (this._components[index] = comp);
    }

    private _hydrateProperty(index: number): Property {
        if (!this._properties) {
            this._properties = [];
            this._hydratedPropertyCount = 0;
        }

        if (this._properties[index]) {
            return this._properties[index];
        }

        const prop = new Property(
            this.jCal[PROPERTY_INDEX][index],
            this
        );

        this._hydratedPropertyCount++;
        return (this._properties[index] = prop);
    }

    /**
     * Finds first sub component, optionally filtered by name.
     */
    getFirstSubcomponent(name?: string): Component | null {
        if (name) {
            const comps = this.jCal[COMPONENT_INDEX];
            const len = comps.length;

            for (let i = 0; i < len; i++) {
                if (comps[i][NAME_INDEX] === name) {
                    return this._hydrateComponent(i);
                }
            }
        } else {
            if (this.jCal[COMPONENT_INDEX].length) {
                return this._hydrateComponent(0);
            }
        }

        return null;
    }

    /**
     * Finds all sub components, optionally filtering by name.
     */
    getAllSubcomponents(name?: string): Component[] {
        const jCalLen = this.jCal[COMPONENT_INDEX].length;

        if (name) {
            const comps = this.jCal[COMPONENT_INDEX];
            const result: Component[] = [];

            for (let i = 0; i < jCalLen; i++) {
                if (name === comps[i][NAME_INDEX]) {
                    result.push(this._hydrateComponent(i));
                }
            }
            return result;
        } else {
            if (!this._components || (this._hydratedComponentCount !== jCalLen)) {
                for (let i = 0; i < jCalLen; i++) {
                    this._hydrateComponent(i);
                }
            }

            return this._components || [];
        }
    }

    /**
     * Returns true when a named property exists.
     */
    hasProperty(name: string): boolean {
        const props = this.jCal[PROPERTY_INDEX];
        const len = props.length;

        for (let i = 0; i < len; i++) {
            if (props[i][NAME_INDEX] === name) {
                return true;
            }
        }

        return false;
    }

    /**
     * Finds the first property, optionally with the given name.
     */
    getFirstProperty(name?: string): Property | null {
        if (name) {
            const props = this.jCal[PROPERTY_INDEX];
            const len = props.length;

            for (let i = 0; i < len; i++) {
                if (props[i][NAME_INDEX] === name) {
                    return this._hydrateProperty(i);
                }
            }
        } else {
            if (this.jCal[PROPERTY_INDEX].length) {
                return this._hydrateProperty(0);
            }
        }

        return null;
    }

    /**
     * Returns first property's value, if available.
     */
    getFirstPropertyValue(name?: string): unknown {
        const prop = this.getFirstProperty(name);
        if (prop) {
            return prop.getFirstValue();
        }

        return null;
    }

    /**
     * Get all properties in the component, optionally filtered by name.
     */
    getAllProperties(name?: string): Property[] {
        const jCalLen = this.jCal[PROPERTY_INDEX].length;

        if (name) {
            const props = this.jCal[PROPERTY_INDEX];
            const result: Property[] = [];

            for (let i = 0; i < jCalLen; i++) {
                if (name === props[i][NAME_INDEX]) {
                    result.push(this._hydrateProperty(i));
                }
            }
            return result;
        } else {
            if (!this._properties || (this._hydratedPropertyCount !== jCalLen)) {
                for (let i = 0; i < jCalLen; i++) {
                    this._hydrateProperty(i);
                }
            }

            return this._properties || [];
        }
    }

    private _removeObjectByIndex(jCalIndex: number, cache: any[] | null, index: number): void {
        cache = cache || [];
        if (cache[index]) {
            const obj = cache[index];
            if ("parent" in obj) {
                obj.parent = null;
            }
        }

        cache.splice(index, 1);
        (this.jCal[jCalIndex] as any[]).splice(index, 1);
    }

    private _removeObject(jCalIndex: number, cacheName: '_components' | '_properties', nameOrObject: string | Component | Property): boolean {
        const objects = this.jCal[jCalIndex] as any[];
        const len = objects.length;
        const cached = this[cacheName];

        if (typeof nameOrObject === 'string') {
            for (let i = 0; i < len; i++) {
                if (objects[i][NAME_INDEX] === nameOrObject) {
                    this._removeObjectByIndex(jCalIndex, cached, i);
                    return true;
                }
            }
        } else if (cached) {
            for (let i = 0; i < len; i++) {
                if (cached[i] && cached[i] === nameOrObject) {
                    this._removeObjectByIndex(jCalIndex, cached, i);
                    return true;
                }
            }
        }

        return false;
    }

    private _removeAllObjects(jCalIndex: number, cacheName: '_components' | '_properties', name?: string): void {
        const cached = this[cacheName];
        const objects = this.jCal[jCalIndex] as any[];

        for (let i = objects.length - 1; i >= 0; i--) {
            if (!name || objects[i][NAME_INDEX] === name) {
                this._removeObjectByIndex(jCalIndex, cached, i);
            }
        }
    }

    /**
     * Adds a single sub component.
     */
    addSubcomponent(component: Component): Component {
        if (!this._components) {
            this._components = [];
            this._hydratedComponentCount = 0;
        }

        if (component.parent) {
            component.parent.removeSubcomponent(component);
        }

        const idx = this.jCal[COMPONENT_INDEX].push(component.jCal);
        this._components[idx - 1] = component;
        this._hydratedComponentCount++;
        component.parent = this;
        return component;
    }

    /**
     * Removes a single component by name or the instance.
     */
    removeSubcomponent(nameOrComp: Component | string): boolean {
        const removed = this._removeObject(COMPONENT_INDEX, '_components', nameOrComp);
        if (removed) {
            this._hydratedComponentCount--;
        }
        return removed;
    }

    /**
     * Removes all components or (if given) all components by a particular name.
     */
    removeAllSubcomponents(name?: string): void {
        this._removeAllObjects(COMPONENT_INDEX, '_components', name);
        this._hydratedComponentCount = 0;
    }

    /**
     * Adds a Property to the component.
     */
    addProperty(property: Property): Property {
        if (!(property instanceof Property)) {
            throw new TypeError('must be instance of ICAL.Property');
        }

        if (!this._properties) {
            this._properties = [];
            this._hydratedPropertyCount = 0;
        }

        if (property.parent) {
            property.parent.removeProperty(property);
        }

        const idx = this.jCal[PROPERTY_INDEX].push(property.jCal);
        this._properties[idx - 1] = property;
        this._hydratedPropertyCount++;
        property.parent = this;
        return property;
    }

    /**
     * Helper method to add a property with a value to the component.
     */
    addPropertyWithValue(name: string, value: unknown): Property {
        const prop = new Property(name);
        prop.setValue(value);
        this.addProperty(prop);
        return prop;
    }

    /**
     * Helper method that will update or create a property.
     */
    updatePropertyWithValue(name: string, value: unknown): Property {
        let prop = this.getFirstProperty(name);

        if (prop) {
            prop.setValue(value);
        } else {
            prop = this.addPropertyWithValue(name, value);
        }

        return prop;
    }

    /**
     * Removes a single property by name or the instance.
     */
    removeProperty(nameOrProp: string | Property): boolean {
        const removed = this._removeObject(PROPERTY_INDEX, '_properties', nameOrProp);
        if (removed) {
            this._hydratedPropertyCount--;
        }
        return removed;
    }

    /**
     * Removes all properties associated with this component.
     */
    removeAllProperties(name?: string): void {
        this._removeAllObjects(PROPERTY_INDEX, '_properties', name);
        this._hydratedPropertyCount = 0;
    }

    /**
     * Returns the Object representation of this component.
     */
    toJSON(): JCalComponent {
        return this.jCal;
    }

    /**
     * The string representation of this component.
     */
    toString(): string {
        return stringify.component(this.jCal, this._designSet);
    }

    /**
     * Retrieve a time zone definition from the component tree.
     */
    getTimeZoneByID(tzid: string): any | null {
        if (this.parent) {
            return this.parent.getTimeZoneByID(tzid);
        }

        if (!this._timezoneCache) {
            return null;
        }

        if (this._timezoneCache.has(tzid)) {
            return this._timezoneCache.get(tzid);
        }

        const zones = this.getAllSubcomponents('vtimezone');
        for (const zone of zones) {
            if (zone.getFirstProperty('tzid')?.getFirstValue() === tzid) {
                const hydratedZone = new Timezone({
                    component: zone,
                    tzid: tzid,
                });

                this._timezoneCache.set(tzid, hydratedZone);
                return hydratedZone;
            }
        }

        return null;
    }
}

export default Component;
