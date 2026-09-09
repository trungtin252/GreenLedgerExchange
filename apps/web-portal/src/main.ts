import { createApp } from 'vue';
import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query';
import { createPinia } from 'pinia';
import App from './App.vue';
import { router } from './router';
import './styles.css';

const app = createApp(App);
app.use(createPinia());
app.use(VueQueryPlugin, { queryClient: new QueryClient() });
app.use(router);
app.mount('#app');
