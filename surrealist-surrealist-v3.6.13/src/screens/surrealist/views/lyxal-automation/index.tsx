import { mdiLightningBolt, mdiMagnify, mdiBellOutline, mdiHelpCircleOutline } from "@mdi/js";
import { Sidebar } from "./components/Sidebar";
import { Overview } from "./components/Overview";
import { useState } from "react";
import { ActionIcon, Group, TextInput, Tooltip } from "@mantine/core";
import { Icon } from "~/components/Icon";
import classes from "./style.module.scss";

export function LyxalAutomationView() {
    const [activeSection, setActiveSection] = useState("overview");

    return (
        <div className={classes.root}>
            <div className={classes.globalHeader}>
                <Group px={24} justify="space-between" style={{ width: '100%' }}>
                    <div style={{ fontWeight: 700, fontSize: 18 }}>Automation</div>
                    
                    <Group style={{ flex: 1, maxWidth: 600 }} justify="center">
                        <TextInput 
                            placeholder="Quick search..." 
                            leftSection={<Icon path={mdiMagnify} size={0.8} />}
                            style={{ width: '100%' }}
                            radius="md"
                            variant="filled"
                        />
                    </Group>

                    <Group gap="sm">
                        <Tooltip label="Notifications">
                            <ActionIcon variant="subtle" color="gray" size="lg">
                                <Icon path={mdiBellOutline} size={0.8} />
                            </ActionIcon>
                        </Tooltip>
                        <Tooltip label="Help">
                            <ActionIcon variant="subtle" color="gray" size="lg">
                                <Icon path={mdiHelpCircleOutline} size={0.8} />
                            </ActionIcon>
                        </Tooltip>
                    </Group>
                </Group>
            </div>

            <div className={classes.main}>
                <Sidebar active={activeSection} onActiveChange={setActiveSection} />
                <div className={classes.content}>
                    <div className={classes.timeline}>
                        {activeSection === "overview" ? (
                            <Overview />
                        ) : (
                            <div style={{ textAlign: 'center', marginTop: 100 }}>
                                <h2 style={{ marginBottom: 8 }}>{activeSection.charAt(0).toUpperCase() + activeSection.slice(1)} View</h2>
                                <p style={{ color: 'var(--surrealist-text-dimmed)' }}>Cette section est en cours de développement.</p>
                            </div>
                        )}
                    </div>
                    <div className={classes.footer}>
                        {/* Footer is empty and slimmer */}
                    </div>
                </div>
            </div>
        </div>
    );
}



export const LyxalAutomationIcon = mdiLightningBolt;
export const LyxalAutomationTitle = "Automation";
