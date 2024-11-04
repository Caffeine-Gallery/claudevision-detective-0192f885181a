export const idlFactory = ({ IDL }) => {
  const Result = IDL.Variant({ 'ok' : IDL.Text, 'err' : IDL.Text });
  return IDL.Service({
    'detectObjects' : IDL.Func([IDL.Text, IDL.Text], [Result], []),
  });
};
export const init = ({ IDL }) => { return []; };
