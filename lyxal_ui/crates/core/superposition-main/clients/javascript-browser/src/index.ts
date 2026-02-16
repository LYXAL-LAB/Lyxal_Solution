import { deepMerge } from "./utils/deepMerge";
import logic from "./logic";
import {
    IObject,
    Dimension,
    Experiments,
    Variant,
    VariantType,
    Variants,
} from "./types";

type DataFromCacApi = {
    contexts: Array<Dimension>;
    overrides: IObject;
    default_configs: IObject;
};

export class CacReader {
    contexts: Array<Dimension>;
    overrides: IObject;
    defaultConfig: IObject;

    constructor(completeConfig: DataFromCacApi) {
        this.contexts = completeConfig.contexts;
        this.overrides = completeConfig.overrides;
        this.defaultConfig = completeConfig.default_configs;
    }

    public evaluateConfig(data: IObject): IObject {
        const requiredOverrides: Array<IObject> = [];
        for (let i = 0; i < this.contexts.length; i++) {
            try {
                if (logic.apply(this.contexts[i].condition, data)) {
                    requiredOverrides.push(
                        ...this.contexts[i].override_with_keys.map(
                            (x) => this.overrides[x]
                        )
                    );
                }
            } catch (e) {
                console.error(e);
            }
        }

        const targetConfig: IObject = { ...this.defaultConfig };
        return deepMerge(targetConfig, ...requiredOverrides);
    }
}

export class ExperimentReader {
    experiments: Experiments;

    constructor(experiments: Experiments) {
        this.experiments = experiments;
    }

    public getApplicableVariants(data: IObject, toss: number): Array<String> {
        if (!Number.isInteger(toss)) {
            throw new Error("Invalid toss, valid range: -1 to 100");
        }
        const experiments = this.getSatisfiedExperiments(data);
        const variants = [];
        for (const exp of experiments) {
            const v = this.decideVariant(
                exp.traffic_percentage,
                exp.variants,
                toss
            );
            if (v) {
                variants.push(v.id);
            }
        }
        return variants;
    }

    getSatisfiedExperiments(data: IObject): Experiments {
        return this.experiments.filter((exp) =>
            logic.apply(exp.context as any, data)
        );
    }

    // decide which variant to return among all applicable experiments
    decideVariant(
        traffic: number,
        applicable_variants: Variants,
        toss: number
    ): Variant | undefined {
        if (!Number.isInteger(traffic) || !Number.isInteger(toss)) {
            return undefined;
        }
        if (toss < 0) {
            for (const variant of applicable_variants) {
                if (variant.variant_type == VariantType.EXPERIMENTAL) {
                    return variant;
                }
            }
        }
        const variant_count = applicable_variants.length;
        const range = traffic * variant_count;
        if (toss >= range) {
            return undefined;
        }
        const index = Math.floor(toss / traffic);
        return applicable_variants[index];
    }
}
