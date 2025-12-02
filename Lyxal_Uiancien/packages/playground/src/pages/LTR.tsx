import React from 'react';
import { Main } from '../layouts';
import { Component } from '../components';

const LTRPage: React.FC = () => {
  return (
    <Main dir="ltr" theme="light">
      <Component />
    </Main>
  );
};

export default LTRPage;
