// EventRunner minimal: stub d'exécution des événements d'un item

export class EventRunner {
  static async runForItem(_itemId: string): Promise<void> {
    // TODO: lire configuration_ui_item_event -> configuration_ui_event -> configuration_ui_route
    // Pour l'instant, ne fait rien (pas de DB branchée)
    return Promise.resolve();
  }
}


