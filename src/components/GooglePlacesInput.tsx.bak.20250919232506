import * as React from "react";

type SetState<T> = React.Dispatch<React.SetStateAction<T>>;

type Props = Omit<React.InputHTMLAttributes<HTMLInputElement>, "onChange" | "value"> & {
  value?: string;
  /**
   * Accepts either:
   * - a standard React state setter (setValue)
   * - a simple callback that receives the string value
   */
  onChange?: SetState<string> | ((value: string) => void);
};

/**
 * Temporary stub for GooglePlacesInput.
 * Accepts all native <input> props and passes them through.
 * Works with either a state setter or a (value)=>void callback.
 */
export default function GooglePlacesInput({
  value = "",
  onChange,
  className,
  placeholder = "Enter an address",
  ...rest
}: Props) {
  const [val, setVal] = React.useState(value ?? "");

  React.useEffect(() => {
    setVal(value ?? "");
  }, [value]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const v = e.currentTarget.value;
    setVal(v);
    if (typeof onChange === "function") {
      // If it's a state setter, it accepts SetStateAction<string>
      // If it's a simple callback, it accepts string
      // We can safely call either:
      (onChange as any)(v);
    }
  };

  return (
    <input
      className={className || "w-full rounded-xl border px-3 py-2"}
      type="text"
      inputMode="text"
      autoComplete="street-address"
      placeholder={placeholder}
      value={val}
      onChange={handleChange}
      {...rest}
    />
  );
}
