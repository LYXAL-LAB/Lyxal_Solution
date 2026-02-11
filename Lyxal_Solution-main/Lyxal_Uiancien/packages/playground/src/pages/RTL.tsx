import React from 'react';
import { Main } from '../layouts';
import { Component } from '../components';

const RTLPage: React.FC = () => {
  return (
    <Main dir="rtl" theme="light">
      <Component />
    </Main>
  );
};

export default RTLPage;
