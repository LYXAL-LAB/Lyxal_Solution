export const navigateAction = (params, context) => {
    const { navigate } = context;
    const { url } = params;
    if (!url) {
        console.warn('[navigateAction] url is required');
        return;
    }
    navigate(url);
};
